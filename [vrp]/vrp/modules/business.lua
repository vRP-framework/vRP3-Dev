-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.business then return end

local lang = vRP.lang

local Business = class("Business", vRP.Extension)

-- NOTE: deliberately no Business.User subclass -- unlike Vehicle (per-
-- character cdata ownership), business ownership is global/per-location, so
-- state lives on the extension instance (self.owners), persisted via the
-- global server-data store (setSData/getSData), not per-character cdata.

local function save_owner(self, id)
  vRP:setSData("vRP:business:"..id, msgpack.pack(self.owners[id]))
end

local function clear_owner(self, id)
  self.owners[id] = nil
  vRP:setSData("vRP:business:"..id, "")
end

-- +/- cfg.revenue_fee_variance_pct fluctuation around a computed fee/revenue
-- amount, so profit doesn't read as a dead-flat number every cycle. Applied
-- once per get_daily_fee/get_utility_fee/get_daily_revenue call, so if a
-- sweep pass catches up multiple elapsed cycles at once (e.g. after
-- downtime), that whole batch shares one roll rather than one per day --
-- an accepted simplification, matching how cycles are already batched
-- elsewhere in this module.
local function apply_variance(self, amount)
  local variance = self.revenue_fee_variance_pct or 0
  if variance <= 0 or amount == 0 then return amount end
  local roll = 1 + (math.random() * 2 - 1) * (variance / 100)
  return amount * roll
end

-- effective daily/utility fee for a business: its own override field if
-- set, else rate * effective price (same override precedence as the
-- purchase price itself). Rate is the per-kind override if one exists,
-- else the flat global rate.
local function get_daily_fee(self, bcfg)
  local rate = self.daily_fee_rate_by_kind[bcfg.kind] or self.daily_fee_rate
  local base = bcfg.daily_fee or ((bcfg.price or self.category_prices[bcfg.kind] or 0) * rate)
  return apply_variance(self, base)
end

local function get_utility_fee(self, bcfg)
  local rate = self.utility_fee_rate_by_kind[bcfg.kind] or self.utility_fee_rate
  local base = bcfg.utility_fee or ((bcfg.price or self.category_prices[bcfg.kind] or 0) * rate)
  return apply_variance(self, base)
end

-- simulated baseline daily revenue for every kind (ambient/NPC-driven
-- average sales) -- inventory-backed kinds will eventually add real
-- player-purchase revenue on top of this once a point-of-sale system
-- exists (see runFeeSweep), not replace it
local function get_daily_revenue(self, bcfg)
  if bcfg.daily_revenue then return apply_variance(self, bcfg.daily_revenue) end
  local rate = self.daily_revenue_rate_by_kind[bcfg.kind] or self.daily_revenue_rate
  return apply_variance(self, (bcfg.price or self.category_prices[bcfg.kind] or 0) * rate)
end

-- fill in fee-tracking fields missing on records saved before this system
-- existed (or freshly hydrated), without forcing an immediate save
local function ensure_fee_fields(owner, now)
  owner.balance = owner.balance or 0
  owner.last_daily_charge = owner.last_daily_charge or owner.purchased_at or now
  owner.last_utility_charge = owner.last_utility_charge or owner.purchased_at or now
  owner.last_daily_fee = owner.last_daily_fee or 0
  owner.last_daily_revenue = owner.last_daily_revenue or 0
  owner.last_utility_fee = owner.last_utility_fee or 0
  owner.last_payroll = owner.last_payroll or owner.purchased_at or now
  owner.last_payroll_paid = owner.last_payroll_paid or 0
  owner.last_profit_withdrawn = owner.last_profit_withdrawn or 0
  owner.last_period_profit = owner.last_period_profit or 0
  owner.pending_profit = owner.pending_profit or 0
  owner.period_revenue = owner.period_revenue or 0
  owner.period_fees = owner.period_fees or 0
end

-- sum of all staff wages (player + NPC alike -- NPC wages are still a real
-- expense, they just have nobody to receive the money)
local function get_total_wage(owner)
  local total = 0
  for _, s in ipairs(owner.staff or {}) do total = total + (s.wage or 0) end
  return total
end

-- an NPC filling a can_manage position is what makes payroll automatic --
-- reuses the existing delegated-access flag rather than matching on the
-- free-text role name, since role is pure RP flavor text elsewhere
local function has_npc_manager(owner)
  for _, s in ipairs(owner.staff or {}) do
    if s.is_npc and s.can_manage then return true end
  end
  return false
end

-- whole payroll cycles elapsed since the last processing
local function payroll_cycles(self, owner, now)
  return math.floor((now - owner.last_payroll) / (self.payroll_period_days * self.day_length))
end

-- pays out `cycles` worth of staff wages from the business balance, crediting
-- online player-staff directly and accruing pending_wage for offline ones
-- (paid on their next login, see playerSpawn below). Same math regardless of
-- who/what triggers it (manual owner/manager click, or the automatic
-- NPC-manager sweep path) -- only the cadence differs.
--
-- also closes out this payroll period's profit accounting: period_revenue/
-- period_fees accumulate daily/utility sweep activity since the last time
-- payroll ran (see runFeeSweep), so "period_profit" here is what this
-- specific day/week cycle actually earned after its own fees and wages --
-- not a share of the whole historical balance. Resets both accumulators for
-- the next period. Returns total_wage, period_profit.
local function pay_wages(self, id, owner, cycles)
  if cycles <= 0 then return 0, 0 end

  local total_wage = cycles * get_total_wage(owner)
  owner.balance = owner.balance - total_wage

  for _, s in ipairs(owner.staff or {}) do
    if not s.is_npc then
      local due = cycles * (s.wage or 0) + (s.pending_wage or 0)
      local target = vRP.users[s.cid]
      if target then
        target:giveWallet(due)
        vRP.EXT.Base.remote._notify(target.source, lang.business.manage.payroll.process.wage_paid({due, self.businesses[id].title}))
        s.pending_wage = 0
      else
        s.pending_wage = due
      end
    end
  end

  owner.last_payroll_paid = total_wage

  -- snapshot the gross period profit (before wages) since period_revenue/
  -- period_fees reset right below -- without this, the live "Weekly Profit"
  -- figure would just read $0 the moment payroll processes, with no way to
  -- see what the period actually generated before wages/withdrawal came out
  local gross_period_profit = (owner.period_revenue or 0) - (owner.period_fees or 0)
  owner.last_period_profit = gross_period_profit
  local period_profit = gross_period_profit - total_wage
  owner.period_revenue = 0
  owner.period_fees = 0

  return total_wage, period_profit
end

-- owner's profit take for this processing pass, per their stored
-- fixed-amount-or-percentage preference (0 if not yet configured -- payroll
-- never guesses a withdrawal on the owner's behalf). Percent mode is a share
-- of this period's profit (see pay_wages), not the full running balance --
-- clamped to 0 so a loss-making period can't produce a negative "withdrawal".
-- Fixed mode is unaffected by period profit, same as before.
local function get_payroll_withdraw(owner, period_profit)
  if not owner.payroll_mode then return 0 end
  if owner.payroll_mode == "percent" then
    return math.floor(math.max(0, period_profit) * (owner.payroll_value or 0) / 100)
  else
    return math.floor(owner.payroll_value or 0)
  end
end

-- prompts the owner for their payroll withdrawal preference (fixed $ or a
-- % of profit) and saves it. Shared by the explicit "Payroll Settings"
-- action and the inline first-time setup offered from "Process Payroll".
-- Returns true if a preference was saved.
local function configure_payroll(self, user, id)
  local owner = self.owners[id]
  if not owner or owner.owner_cid ~= user.cid then return false end

  local use_percent = user:request(lang.business.manage.payroll.settings.confirm_percent(), 15)

  -- re-check post-prompt: ownership may have changed during the wait
  owner = self.owners[id]
  if not owner or owner.owner_cid ~= user.cid then return false end

  local value
  if use_percent then
    local input = user:prompt(lang.business.manage.payroll.settings.prompt_percent(), tostring(owner.payroll_value or 50))
    value = tonumber(input)
    if not value or value <= 0 or value > 100 or value ~= value then return false end
  else
    local input = user:prompt(lang.business.manage.payroll.settings.prompt_fixed(), tostring(owner.payroll_value or 0))
    value = tonumber(input)
    if not value or value < 0 or value ~= value then return false end
    value = math.floor(value)
  end

  -- re-check post-prompt again
  owner = self.owners[id]
  if not owner or owner.owner_cid ~= user.cid then return false end

  owner.payroll_mode = use_percent and "percent" or "fixed"
  owner.payroll_value = value
  save_owner(self, id)

  vRP.EXT.Base.remote._notify(user.source, lang.business.manage.payroll.settings.updated(
    {owner.payroll_mode == "percent" and (owner.payroll_value.."%%") or ("$"..owner.payroll_value)}))
  return true
end

-- staff roster helpers. owner.staff is an array of
-- {cid, role (free-text flavor), wage, can_manage, hired_at}. Role is
-- purely RP flavor text, not a permission -- can_manage is the actual
-- delegated-access grant, set explicitly by the owner at hire time.
local function find_staff(owner, cid)
  for i, s in ipairs(owner.staff or {}) do
    if s.cid == cid then return s, i end
  end
  return nil
end

local function staff_can_manage(owner, cid)
  local s = find_staff(owner, cid)
  return s ~= nil and s.can_manage == true
end

-- display name for the owner, from the perspective of `viewer_cid` -- "You"
-- if they are the owner (e.g. a delegated manager viewing who actually owns
-- the business), else the owner's identity name
local function owner_display_name(owner, viewer_cid)
  if owner.owner_cid == viewer_cid then return lang.common.you() end
  local identity = vRP.EXT.Identity and vRP.EXT.Identity:getIdentity(owner.owner_cid)
  return (identity and (identity.firstname or "").." "..(identity.name or "")) or "someone"
end

-- "+$20"/"-$20" style signed display for a profit figure
local function format_signed_money(amount)
  amount = math.floor(amount)
  if amount >= 0 then return "+$"..amount else return "-$"..math.abs(amount) end
end

-- menu: business (single adaptive builder -- branches on live ownership
-- state instead of separate buy/manage menu types, since ownership can
-- change while the same player is still standing in the trigger area)
local function menu_business(self)
  local function m_purchase(menu, id)
    local user = menu.user
    local bcfg = self.businesses[id]

    if self.owners[id] then
      return vRP.EXT.Base.remote._notify(user.source, lang.business.buy.already_owned())
    end

    local price = bcfg.price or self.category_prices[bcfg.kind]

    if not user:request(lang.business.buy.confirm({bcfg.title, price}), 15) then return end

    -- re-check post-confirm: another player may have bought it during the wait
    if self.owners[id] then
      return vRP.EXT.Base.remote._notify(user.source, lang.business.buy.already_owned())
    end

    if not user:tryPayment(price) then
      return vRP.EXT.Base.remote._notify(user.source, lang.money.not_enough())
    end

    local now = os.time()
    self.owners[id] = {
      owner_cid = user.cid, purchased_at = now,
      balance = 0, last_daily_charge = now, last_utility_charge = now,
    }
    save_owner(self, id)

    vRP.EXT.Base.remote._notify(user.source, lang.business.buy.purchased({bcfg.title}))
    user:actualizeMenu()
  end

  local function m_deposit(menu, id)
    local user = menu.user
    local owner = self.owners[id]
    if not owner or owner.owner_cid ~= user.cid then return end

    local input = user:prompt(lang.business.manage.deposit.prompt(), "")
    local amount = tonumber(input)
    if not amount or amount <= 0 or amount ~= amount then return end -- amount~=amount rejects NaN
    amount = math.floor(amount)

    if not user:tryPayment(amount) then
      return vRP.EXT.Base.remote._notify(user.source, lang.money.not_enough())
    end

    ensure_fee_fields(owner, os.time())
    owner.balance = owner.balance + amount
    save_owner(self, id)

    vRP.EXT.Base.remote._notify(user.source, lang.business.manage.deposit.added({amount}))
    user:actualizeMenu()
  end

  -- shared by do_hire (new position) and do_assign (filling an existing
  -- NPC slot) -- sends the offer to nuser and returns true/false
  local function offer_position(nuser, role, wage, title)
    return nuser:request(lang.business.manage.staff.hire.offer({role, wage, title}), 15)
  end

  -- nearby players excluding the owner themself, keyed by source -> distance
  local function nearby_candidates(user)
    local candidates = vRP.EXT.Base.remote.getNearestPlayers(user.source, 10) or {}
    candidates[user.source] = nil
    return candidates
  end

  -- create a new staff position. nuser nil = NPC hire.
  local function do_hire(user, id, nuser)
    local owner = self.owners[id]
    if not owner or owner.owner_cid ~= user.cid then return end

    local has_target = nuser ~= nil
    if has_target and find_staff(owner, nuser.cid) then
      return vRP.EXT.Base.remote._notify(user.source, lang.business.manage.staff.hire.already_staff())
    end

    local role = user:prompt(lang.business.manage.staff.hire.prompt_role(), "")
    if not role or role == "" then return end

    local wage_input = user:prompt(lang.business.manage.staff.hire.prompt_wage(), "0")
    local wage = tonumber(wage_input)
    if not wage or wage < 0 or wage ~= wage then return end
    wage = math.floor(wage)

    local grant_manage = user:request(lang.business.manage.staff.hire.confirm_manage({role}), 15)

    if has_target then
      if not offer_position(nuser, role, wage, self.businesses[id].title) then
        return vRP.EXT.Base.remote._notify(user.source, lang.business.manage.staff.hire.declined())
      end
    else
      if not user:request(lang.business.manage.staff.hire.confirm_npc({role}), 15) then return end
    end

    -- re-check post-prompts: ownership/roster may have changed during the wait
    owner = self.owners[id]
    if not owner or owner.owner_cid ~= user.cid then return end
    if has_target and find_staff(owner, nuser.cid) then return end

    owner.staff = owner.staff or {}
    table.insert(owner.staff, {
      cid = has_target and nuser.cid or nil, is_npc = not has_target,
      role = role, wage = wage, can_manage = grant_manage and true or false, hired_at = os.time(),
    })
    save_owner(self, id)

    vRP.EXT.Base.remote._notify(user.source, lang.business.manage.staff.hire.hired({role}))
    if has_target then
      vRP.EXT.Base.remote._notify(nuser.source, lang.business.manage.staff.hire.hired_notify({role, self.businesses[id].title}))
    end
    user:actualizeMenu()
  end

  -- swap a player into an existing NPC-filled position
  local function do_assign(user, id, index, nuser)
    local owner = self.owners[id]
    if not owner or owner.owner_cid ~= user.cid then return end
    local s = owner.staff and owner.staff[index]
    if not s or not s.is_npc then return end

    if find_staff(owner, nuser.cid) then
      return vRP.EXT.Base.remote._notify(user.source, lang.business.manage.staff.hire.already_staff())
    end

    if not offer_position(nuser, s.role, s.wage, self.businesses[id].title) then
      return vRP.EXT.Base.remote._notify(user.source, lang.business.manage.staff.hire.declined())
    end

    -- re-check post-offer: slot/ownership/roster may have changed during the wait
    owner = self.owners[id]
    s = owner and owner.staff and owner.staff[index]
    if not owner or owner.owner_cid ~= user.cid or not s or not s.is_npc then return end
    if find_staff(owner, nuser.cid) then return end

    s.is_npc = false
    s.cid = nuser.cid
    save_owner(self, id)

    vRP.EXT.Base.remote._notify(user.source, lang.business.manage.staff.hire.hired({s.role}))
    vRP.EXT.Base.remote._notify(nuser.source, lang.business.manage.staff.hire.hired_notify({s.role, self.businesses[id].title}))
    user:actualizeMenu()
  end

  -- entry point: owner clicks "Hire Staff" -- opens a picker if any nearby
  -- players exist, otherwise goes straight to the NPC-hire path
  local function m_hire(menu, id)
    local user = menu.user
    local owner = self.owners[id]
    if not owner or owner.owner_cid ~= user.cid then return end

    local candidates = nearby_candidates(user)
    if next(candidates) == nil then
      return do_hire(user, id, nil)
    end

    user:openMenu("business.staff.pick", {id = id, candidates = candidates})
  end

  -- entry point: owner clicks "Assign Player" on an NPC slot -- always a
  -- picker (no NPC option here, there must be a real player to assign)
  local function m_assign_player(menu, data)
    local user = menu.user
    local owner = self.owners[data.id]
    if not owner or owner.owner_cid ~= user.cid then return end
    local s = owner.staff and owner.staff[data.index]
    if not s or not s.is_npc then return end

    local candidates = nearby_candidates(user)
    if next(candidates) == nil then
      return vRP.EXT.Base.remote._notify(user.source, lang.common.no_player_near())
    end

    user:openMenu("business.staff.pick", {id = data.id, index = data.index, assign = true, candidates = candidates})
  end

  -- picker selection: routes to do_hire or do_assign depending on how the
  -- picker was opened. Re-fetches the user by cid rather than trusting the
  -- candidate list's source, in case they disconnected since the list was built
  local function m_pick_player(menu, data)
    local user = menu.user
    local nuser = vRP.users[data.cid]
    if not nuser or not vRP.users_by_source[nuser.source] then
      return vRP.EXT.Base.remote._notify(user.source, lang.common.no_player_near())
    end

    if data.assign then
      do_assign(user, data.id, data.index, nuser)
    else
      do_hire(user, data.id, nuser)
    end
  end

  local function m_pick_npc(menu, id)
    do_hire(menu.user, id, nil)
  end

  local function m_adjust_wage(menu, data)
    local user = menu.user
    local owner = self.owners[data.id]
    if not owner or owner.owner_cid ~= user.cid then return end
    local s = owner.staff and owner.staff[data.index]
    if not s then return end

    local input = user:prompt(lang.business.manage.staff.adjust_wage.prompt({s.wage}), tostring(s.wage))
    local new_wage = tonumber(input)
    if not new_wage or new_wage < 0 or new_wage ~= new_wage then return end
    new_wage = math.floor(new_wage)

    -- re-check post-prompt: roster may have changed during the wait
    owner = self.owners[data.id]
    s = owner and owner.staff and owner.staff[data.index]
    if not owner or owner.owner_cid ~= user.cid or not s then return end

    s.wage = new_wage
    save_owner(self, data.id)

    vRP.EXT.Base.remote._notify(user.source, lang.business.manage.staff.adjust_wage.updated({new_wage}))
    if not s.is_npc then
      local target = vRP.users[s.cid]
      if target then
        vRP.EXT.Base.remote._notify(target.source, lang.business.manage.staff.adjust_wage.notify({self.businesses[data.id].title, new_wage}))
      end
    end
    user:actualizeMenu()
  end

  -- one-time bonus, drawn from the business balance into the staff
  -- member's wallet -- player positions only (NPCs have no wallet), and
  -- only while they're online (Money methods operate on a live user object)
  local function m_bonus(menu, data)
    local user = menu.user
    local owner = self.owners[data.id]
    if not owner or owner.owner_cid ~= user.cid then return end
    local s = owner.staff and owner.staff[data.index]
    if not s or s.is_npc then return end

    local target = vRP.users[s.cid]
    if not target then
      return vRP.EXT.Base.remote._notify(user.source, lang.business.manage.staff.bonus.not_online())
    end

    local input = user:prompt(lang.business.manage.staff.bonus.prompt(), "")
    local amount = tonumber(input)
    if not amount or amount <= 0 or amount ~= amount then return end
    amount = math.floor(amount)

    -- re-check post-prompt: roster/online-state may have changed during the wait
    owner = self.owners[data.id]
    s = owner and owner.staff and owner.staff[data.index]
    target = s and not s.is_npc and vRP.users[s.cid]
    if not owner or owner.owner_cid ~= user.cid or not s or not target then return end

    ensure_fee_fields(owner, os.time())
    owner.balance = owner.balance - amount
    save_owner(self, data.id)
    target:giveWallet(amount)

    vRP.EXT.Base.remote._notify(user.source, lang.business.manage.staff.bonus.given({amount}))
    vRP.EXT.Base.remote._notify(target.source, lang.business.manage.staff.bonus.received({amount, self.businesses[data.id].title}))
    user:actualizeMenu()
  end

  local function m_fire(menu, data)
    local user = menu.user
    local owner = self.owners[data.id]
    if not owner or owner.owner_cid ~= user.cid then return end
    if not (owner.staff and owner.staff[data.index]) then return end

    if not user:request(lang.business.manage.staff.fire_confirm(), 15) then return end

    -- re-check post-confirm: roster may have changed during the wait
    owner = self.owners[data.id]
    local s = owner and owner.staff and owner.staff[data.index]
    if not owner or owner.owner_cid ~= user.cid or not s then return end

    local fired_user = vRP.users[s.cid]
    table.remove(owner.staff, data.index)
    save_owner(self, data.id)

    if fired_user then
      vRP.EXT.Base.remote._notify(fired_user.source, lang.business.manage.staff.fired_notify({self.businesses[data.id].title}))
    end
    vRP.EXT.Base.remote._notify(user.source, lang.business.manage.staff.fired())
    user:actualizeMenu()
  end

  local function m_payroll_settings(menu, id)
    local user = menu.user
    local owner = self.owners[id]
    if not owner or owner.owner_cid ~= user.cid then return end

    configure_payroll(self, user, id)
    user:actualizeMenu()
  end

  -- pays out accrued staff wages, then (owner only) offers to withdraw the
  -- remaining profit per the owner's stored fixed-amount-or-percentage
  -- preference -- same math the automatic NPC-manager sweep path uses,
  -- just manually triggered here instead of on a schedule
  local function m_process_payroll(menu, id)
    local user = menu.user
    local owner = self.owners[id]
    if not owner or (owner.owner_cid ~= user.cid and not staff_can_manage(owner, user.cid)) then return end

    local now = os.time()
    ensure_fee_fields(owner, now)
    local cycles = payroll_cycles(self, owner, now)
    if cycles <= 0 then
      return vRP.EXT.Base.remote._notify(user.source, lang.business.manage.payroll.process.none_due())
    end

    local total_wage, period_profit = pay_wages(self, id, owner, cycles)
    owner.last_payroll = owner.last_payroll + cycles * (self.payroll_period_days * self.day_length)
    save_owner(self, id)

    vRP.EXT.Base.remote._notify(user.source, lang.business.manage.payroll.process.wages_paid({total_wage}))
    user:actualizeMenu()

    -- profit withdrawal stays owner-exclusive, same boundary as hire/fire
    -- and Payroll Settings -- a delegated manager only ever pays wages here
    if user.cid ~= owner.owner_cid then return end

    if not owner.payroll_mode then
      if not user:request(lang.business.manage.payroll.settings.setup_now(), 15) then return end
      if not configure_payroll(self, user, id) then return end
    end

    owner = self.owners[id]
    if not owner or owner.owner_cid ~= user.cid or not owner.payroll_mode then return end

    local withdraw = get_payroll_withdraw(owner, period_profit)
    if withdraw <= 0 then return end

    local next_daily = owner.last_daily_charge + self.day_length
    local next_utility = owner.last_utility_charge + (self.utility_period_days * self.day_length)
    local next_charge_at = math.min(next_daily, next_utility)

    if not user:request(lang.business.manage.payroll.process.confirm_withdraw(
      {withdraw, math.floor(owner.balance), os.date("%Y-%m-%d %H:%M", next_charge_at)}), 15) then return end

    -- re-check post-confirm: ownership/balance may have changed during the wait
    owner = self.owners[id]
    if not owner or owner.owner_cid ~= user.cid then return end

    owner.balance = owner.balance - withdraw
    owner.last_profit_withdrawn = withdraw
    save_owner(self, id)
    user:giveWallet(withdraw)

    vRP.EXT.Base.remote._notify(user.source, lang.business.manage.payroll.process.withdrawn({withdraw}))
    user:actualizeMenu()
  end

  local function m_admin_revoke(menu, id)
    local user = menu.user
    if not user:hasPermission("admin.business") then return end
    if not self.owners[id] then return end
    local bcfg = self.businesses[id]

    if not user:request(lang.business.admin.revoke_confirm({bcfg.title}), 15) then return end

    clear_owner(self, id)
    vRP.EXT.Base.remote._notify(user.source, lang.business.admin.revoked())
    user:actualizeMenu()
  end

  -- balance/payroll financial section, shared between the in-person
  -- "business" menu (walking up to the marker) and the remote
  -- "business.remote" menu (My Businesses, reachable from anywhere via the
  -- main/phone menu). Staff roster/hiring and admin actions stay
  -- location-only, added by the caller instead of here.
  local function add_financial_options(menu, id, bcfg, owner, user)
    ensure_fee_fields(owner, os.time())

    local next_payroll_at = owner.last_payroll + (self.payroll_period_days * self.day_length)

    local payroll_display
    if not owner.payroll_mode then
      payroll_display = lang.business.manage.payroll.not_configured()
    elseif owner.payroll_mode == "percent" then
      payroll_display = owner.payroll_value.."%%"
    else
      payroll_display = "$"..owner.payroll_value
    end

    -- daily figures are the real last-billed cycle; "weekly" is the real
    -- period_revenue/period_fees accumulated since the last payroll
    -- processing (same numbers Process Payroll's percentage withdrawal is
    -- based on -- not a daily*7 guess, so this always includes any real
    -- utility-fee hit that landed during the window and matches exactly
    -- what a percentage payout would actually pay out right now)
    local daily_profit = owner.last_daily_revenue - owner.last_daily_fee
    local period_profit_so_far = (owner.period_revenue or 0) - (owner.period_fees or 0)

    -- public info (business + who owns it) followed by the owner/manager-
    -- only financial breakdown
    menu:addOption(lang.business.manage.title(), nil, lang.business.manage.info(
      {bcfg.title, owner_display_name(owner, user.cid), owner.purchased_at,
       math.floor(owner.balance), format_signed_money(daily_profit), format_signed_money(period_profit_so_far),
       "-$"..math.floor(owner.last_daily_fee), "-$"..math.floor(owner.period_fees or 0),
       os.date("%Y-%m-%d %H:%M", next_payroll_at), format_signed_money(owner.last_period_profit),
       math.floor(owner.last_payroll_paid), math.floor(owner.last_profit_withdrawn), payroll_display}))
    menu:addOption(lang.business.manage.deposit.title(), m_deposit, lang.business.manage.deposit.description(), id)
    menu:addOption(lang.business.manage.payroll.process.title(), m_process_payroll, lang.business.manage.payroll.process.description(), id)
    -- future: pricing/stock/income options for this business's `kind`
    -- get appended here without restructuring this function

    -- payroll withdrawal preference stays owner-exclusive -- delegated
    -- managers get the balance/deposit/payroll-processing view above, not
    -- withdrawal-preference control
    if owner.owner_cid == user.cid then
      menu:addOption(lang.business.manage.payroll.settings.title(), m_payroll_settings, lang.business.manage.payroll.settings.description(), id)
    end
  end

  vRP.EXT.GUI:registerMenuBuilder(self, "business", function(menu)
    local id = menu.data.id
    local bcfg = self.businesses[id]
    local owner = self.owners[id]
    local user = menu.user

    menu.title = bcfg.title
    menu.css.header_color = "rgba(0,180,0,0.75)"

    if not owner then
      local price = bcfg.price or self.category_prices[bcfg.kind]
      menu:addOption(lang.business.buy.title(), m_purchase, lang.business.buy.info({price}), id)
    elseif owner.owner_cid == user.cid or staff_can_manage(owner, user.cid) then
      add_financial_options(menu, id, bcfg, owner, user)

      -- hiring/firing stays owner-exclusive and location-gated -- delegated
      -- managers get the financial view above, not roster control. Same
      -- info/payroll actions are also reachable remotely, see
      -- "business.remote" (My Businesses, on the main/phone menu) below.
      if owner.owner_cid == user.cid then
        menu:addOption(lang.business.manage.staff.hire.title(), m_hire, lang.business.manage.staff.hire.description(), id)
        menu:addOption(lang.business.manage.staff.title(), function(menu)
          menu.user:openMenu("business.staff", {id = id})
        end)
      end
    else
      menu:addOption(lang.business.owned_by({owner_display_name(owner, user.cid)}), nil, "")
    end

    if owner and user:hasPermission("admin.business") then
      menu:addOption(lang.business.admin.revoke_title(), m_admin_revoke, lang.business.admin.revoke_description(), id)
    end
  end)

  vRP.EXT.GUI:registerMenuBuilder(self, "business.staff", function(menu)
    local id = menu.data.id
    local owner = self.owners[id]
    local user = menu.user

    menu.title = lang.business.manage.staff.title()
    menu.css.header_color = "rgba(0,180,0,0.75)"

    if not owner or owner.owner_cid ~= user.cid then return end

    for i, s in ipairs(owner.staff or {}) do
      local name
      if s.is_npc then
        name = lang.business.manage.staff.npc_label({s.role})
      else
        local identity = vRP.EXT.Identity and vRP.EXT.Identity:getIdentity(s.cid)
        name = (identity and (identity.firstname or "").." "..(identity.name or "")) or ("cid "..s.cid)
      end

      local info = lang.business.manage.staff.entry_info(
        {s.role, s.wage, s.can_manage and lang.common.yes() or lang.common.no()})

      menu:addOption(name, function(menu)
        menu.user:openMenu("business.staff.entry", {id = id, index = i})
      end, info)
    end
  end)

  vRP.EXT.GUI:registerMenuBuilder(self, "business.staff.entry", function(menu)
    local id = menu.data.id
    local index = menu.data.index
    local owner = self.owners[id]
    local user = menu.user

    if not owner or owner.owner_cid ~= user.cid then return end
    local s = owner.staff and owner.staff[index]
    if not s then return end

    menu.title = s.role
    menu.css.header_color = "rgba(0,180,0,0.75)"

    if s.is_npc then
      menu:addOption(lang.business.manage.staff.assign_player.title(), m_assign_player,
        lang.business.manage.staff.assign_player.description(), {id = id, index = index})
    end

    menu:addOption(lang.business.manage.staff.adjust_wage.title(), m_adjust_wage,
      lang.business.manage.staff.adjust_wage.description(), {id = id, index = index})

    if not s.is_npc then
      menu:addOption(lang.business.manage.staff.bonus.title(), m_bonus,
        lang.business.manage.staff.bonus.description(), {id = id, index = index})
    end

    menu:addOption(lang.business.manage.staff.fire.title(), m_fire,
      lang.business.manage.staff.fire.description(), {id = id, index = index})
  end)

  vRP.EXT.GUI:registerMenuBuilder(self, "business.staff.pick", function(menu)
    local id = menu.data.id
    local index = menu.data.index
    local assign = menu.data.assign
    local candidates = menu.data.candidates or {}
    local user = menu.user

    menu.title = lang.business.manage.staff.hire.pick_title()
    menu.css.header_color = "rgba(0,180,0,0.75)"

    for source, distance in pairs(candidates) do
      local nuser = vRP.users_by_source[source]
      if nuser and nuser.cid ~= user.cid then
        local identity = vRP.EXT.Identity and vRP.EXT.Identity:getIdentity(nuser.cid)
        local name = (identity and (identity.firstname or "").." "..(identity.name or "")) or ("cid "..nuser.cid)
        menu:addOption(name, m_pick_player, lang.business.manage.staff.hire.pick_info({math.floor(distance)}),
          {id = id, index = index, assign = assign, cid = nuser.cid})
      end
    end

    if not assign then
      menu:addOption(lang.business.manage.staff.hire.pick_npc(), m_pick_npc,
        lang.business.manage.staff.hire.pick_npc_description(), id)
    end
  end)

  -- remote/phone equivalent of the in-person financial view -- reachable
  -- from anywhere via "business.mine" below, no need to walk to the
  -- marker. Same balance/deposit/payroll actions as "business", minus the
  -- location-only staff/hiring controls. Purchasing a business intentionally
  -- stays marker-only (see cfg/business.lua) -- this is never a "browse and
  -- buy" menu, only businesses already owned/managed ever show up here.
  vRP.EXT.GUI:registerMenuBuilder(self, "business.remote", function(menu)
    local id = menu.data.id
    local bcfg = self.businesses[id]
    local owner = self.owners[id]
    local user = menu.user

    if not bcfg or not owner or (owner.owner_cid ~= user.cid and not staff_can_manage(owner, user.cid)) then
      return
    end

    menu.title = bcfg.title
    menu.css.header_color = "rgba(0,180,0,0.75)"

    add_financial_options(menu, id, bcfg, owner, user)
  end)

  -- "My Businesses": lists every business this player owns or manages,
  -- each opening the remote financial view above
  vRP.EXT.GUI:registerMenuBuilder(self, "business.mine", function(menu)
    local user = menu.user

    menu.title = lang.business.mine.title()
    menu.css.header_color = "rgba(0,180,0,0.75)"

    for id, owner in pairs(self.owners) do
      local bcfg = self.businesses[id]
      if bcfg and (owner.owner_cid == user.cid or staff_can_manage(owner, user.cid)) then
        menu:addOption(bcfg.title, function(menu)
          menu.user:openMenu("business.remote", {id = id})
        end)
      end
    end
  end)

  -- only shows the "My Businesses" entry point if the player actually owns
  -- or manages at least one business, so it doesn't clutter the main/phone
  -- menu for everyone else
  vRP.EXT.GUI:registerMenuBuilder(self, "main", function(menu)
    local user = menu.user

    for id, owner in pairs(self.owners) do
      if self.businesses[id] and (owner.owner_cid == user.cid or staff_can_manage(owner, user.cid)) then
        menu:addOption(lang.business.mine.title(), function(menu)
          menu.user:openMenu("business.mine")
        end, lang.business.mine.description())
        break
      end
    end
  end)
end

-- METHODS

function Business:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/business")
  self.businesses = self.cfg.businesses
  self.category_prices = self.cfg.category_prices or {}
  self.area_radius = self.cfg.area_radius or 1.5
  self.area_height = self.cfg.area_height or 2.0
  self.daily_fee_rate = self.cfg.daily_fee_rate or 0.003
  self.utility_fee_rate = self.cfg.utility_fee_rate or 0.005
  self.daily_fee_rate_by_kind = self.cfg.daily_fee_rate_by_kind or {}
  self.utility_fee_rate_by_kind = self.cfg.utility_fee_rate_by_kind or {}
  self.daily_revenue_rate_by_kind = self.cfg.daily_revenue_rate_by_kind or {}
  self.revenue_fee_variance_pct = self.cfg.revenue_fee_variance_pct or 0
  self.utility_period_days = self.cfg.utility_period_days or 7
  self.grace_period_days = self.cfg.grace_period_days or 3
  self.fee_sweep_interval = self.cfg.fee_sweep_interval or 300
  self.daily_revenue_rate = self.cfg.daily_revenue_rate or 0.004
  self.day_length = self.cfg.day_length or 2880
  self.payroll_period_days = self.cfg.payroll_period_days or 7
  self.cfg = nil

  self.owners = {} -- id -> {owner_cid=, purchased_at=}
  self._owners_hydrated = false

  -- registered immediately (no I/O) rather than lazily on playerSpawn --
  -- a hot-reload (/vrpReload Business) re-runs this constructor but does
  -- NOT refire playerSpawn for already-connected players, so a lazy
  -- registration would leave their "business" menu with no options until
  -- their next spawn/respawn.
  menu_business(self)

  -- also attempt ownership hydration immediately: safe on a hot-reload
  -- (the DB has been up for a while by then), but on a cold server boot
  -- this may run before the DB is ready, so failures here are non-fatal --
  -- playerSpawn below retries.
  pcall(function() self:hydrateOwners() end)

  -- periodic fee sweep: same guarded-thread shape as group.lua's count
  -- display, stopped via event:unload so /vrpReload or /vrpStop doesn't
  -- leave a duplicate loop running against a dead instance.
  self._sweep_running = true
  Citizen.CreateThread(function()
    while self._sweep_running do
      Citizen.Wait(self.fee_sweep_interval * 1000)
      if not self._sweep_running then break end
      pcall(function() self:runFeeSweep() end)
    end
  end)
end

-- hydrate self.owners from persistent server data; idempotent, safe to
-- call multiple times (only marks itself done once it completes without
-- throwing, so a failed attempt is retried by the next caller)
function Business:hydrateOwners()
  for id in pairs(self.businesses) do
    local raw = vRP:getSData("vRP:business:"..id)
    if raw and #raw > 0 then
      local ok, data = pcall(msgpack.unpack, raw)
      if ok and type(data) == "table" then
        self.owners[id] = data
      else
        vRP:log("warning: failed to unpack business ownership for id="..id)
      end
    end
  end
  self._owners_hydrated = true
end

-- walk all owned businesses, lazily billing elapsed daily/utility fee
-- cycles (by real elapsed time, not a fixed wall-clock tick) against each
-- business's own balance, notifying the owner if online and negative, and
-- repossessing (clear_owner -- which also wipes any accrued debt) once the
-- grace period has elapsed. Called periodically off self._sweep_running.
function Business:runFeeSweep()
  local now = os.time()
  local day = self.day_length
  local utility_period = self.utility_period_days * day
  local grace_period = self.grace_period_days * day

  for id, owner in pairs(self.owners) do
    local bcfg = self.businesses[id]
    if bcfg then
      ensure_fee_fields(owner, now)
      local changed = false

      local daily_cycles = math.floor((now - owner.last_daily_charge) / day)
      if daily_cycles > 0 then
        local revenue = daily_cycles * get_daily_revenue(self, bcfg)
        local fee = daily_cycles * get_daily_fee(self, bcfg)
        owner.balance = owner.balance + revenue - fee
        owner.last_daily_revenue = revenue
        owner.last_daily_fee = fee
        owner.period_revenue = (owner.period_revenue or 0) + revenue
        owner.period_fees = (owner.period_fees or 0) + fee
        owner.last_daily_charge = owner.last_daily_charge + daily_cycles * day
        changed = true
      end

      local utility_cycles = math.floor((now - owner.last_utility_charge) / utility_period)
      if utility_cycles > 0 then
        local utility_fee = utility_cycles * get_utility_fee(self, bcfg)
        owner.balance = owner.balance - utility_fee
        owner.last_utility_fee = utility_fee
        owner.period_fees = (owner.period_fees or 0) + utility_fee
        owner.last_utility_charge = owner.last_utility_charge + utility_cycles * utility_period
        changed = true
      end

      local user = vRP.users[owner.owner_cid]
      local repossessed = false

      if owner.balance < 0 then
        if not owner.negative_since then
          owner.negative_since = now
          changed = true
        end

        if now - owner.negative_since >= grace_period then
          clear_owner(self, id)
          repossessed = true
          if user then
            vRP.EXT.Base.remote._notify(user.source, lang.business.notify.repossessed({bcfg.title}))
          end
        elseif user then
          vRP.EXT.Base.remote._notify(user.source, lang.business.notify.negative_balance({bcfg.title, math.floor(owner.balance)}))
        end
      elseif owner.negative_since then
        owner.negative_since = nil
        changed = true
      end

      -- automatic payroll: only runs for businesses with an NPC manager on
      -- staff (player/manual businesses require someone to click "Process
      -- Payroll" themselves). Wages are always paid on schedule regardless;
      -- the owner's profit withdrawal only auto-runs once they've configured
      -- a fixed/percent preference -- never guessed on their behalf.
      if not repossessed and has_npc_manager(owner) then
        local pcycles = payroll_cycles(self, owner, now)
        if pcycles > 0 then
          local _, period_profit = pay_wages(self, id, owner, pcycles)
          owner.last_payroll = owner.last_payroll + pcycles * (self.payroll_period_days * self.day_length)
          changed = true

          if owner.payroll_mode then
            local withdraw = get_payroll_withdraw(owner, period_profit)
            if withdraw > 0 then
              owner.balance = owner.balance - withdraw
              owner.last_profit_withdrawn = withdraw
              if user then
                user:giveWallet(withdraw)
                vRP.EXT.Base.remote._notify(user.source, lang.business.manage.payroll.process.auto_withdrawn({bcfg.title, withdraw}))
              else
                owner.pending_profit = owner.pending_profit + withdraw
              end
            end
          end
        end
      end

      if changed and not repossessed then save_owner(self, id) end

      -- push a live refresh to the owner if they're online -- otherwise the
      -- balance/next-charge/last-billing info in an already-open manage menu
      -- stays stale until they close and reopen it
      if user and (changed or repossessed) then user:actualizeMenu() end
    end
  end
end

-- EVENT

Business.event = {}

-- called by vRPShared:unregisterExtension; stops the fee-sweep thread so
-- it doesn't keep running against this now-unregistered instance after a
-- /vrpReload or /vrpStop (same pattern as group.lua's count display).
function Business.event:unload()
  self._sweep_running = false
end

function Business.event:playerSpawn(user, first_spawn)
  if not self._owners_hydrated then pcall(function() self:hydrateOwners() end) end
  if first_spawn then
    -- pay out any wage/profit that accrued while this player was offline
    -- (automatic NPC-manager payroll can't credit a live wallet if nobody's
    -- connected, so it accrues here instead and is settled on next login)
    for id, owner in pairs(self.owners) do
      local bcfg = self.businesses[id]
      if bcfg then
        local paid_out = false

        if owner.owner_cid == user.cid and owner.pending_profit and owner.pending_profit > 0 then
          local amount = owner.pending_profit
          owner.pending_profit = 0
          user:giveWallet(amount)
          vRP.EXT.Base.remote._notify(user.source, lang.business.manage.payroll.process.pending_profit_paid({amount, bcfg.title}))
          paid_out = true
        end

        local s = find_staff(owner, user.cid)
        if s and not s.is_npc and s.pending_wage and s.pending_wage > 0 then
          local amount = s.pending_wage
          s.pending_wage = 0
          user:giveWallet(amount)
          vRP.EXT.Base.remote._notify(user.source, lang.business.manage.payroll.process.pending_wage_paid({amount, bcfg.title}))
          paid_out = true
        end

        if paid_out then save_owner(self, id) end
      end
    end

    for id, bcfg in pairs(self.businesses) do
      local x, y, z, radius, height = table.unpack(bcfg.pos)
      if radius == nil then radius = self.area_radius end
      if height == nil then height = self.area_height end

      local menu
      local function enter(user)
        menu = user:openMenu("business", { id = id })
      end
      local function leave(user)
        if menu then user:closeMenu(menu) end
      end

      local ment = clone(bcfg._config.map_entity)
      ment[2].title = bcfg.title
      ment[2].pos = {x, y, z-1}
      vRP.EXT.Map.remote._addEntity(user.source, ment[1], ment[2])

      user:setArea("vRP:business:"..id, x, y, z, radius, height, enter, leave)
    end
  end
end

vRP:registerExtension(Business)
