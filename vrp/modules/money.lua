-- Improved Money Module for vRP3
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.money then return end

local Money = class("Money", vRP.Extension)
Money.User = class("User")  -- -- SUBCLASS

function Money.User:getWallet()
  return self.cdata.wallet
end

function Money.User:getBank()
  return self.cdata.bank
end

-- Internal setters that trigger update events and save changes
function Money.User:setWallet(amount)
  if type(amount) ~= "number" then return false end
	
  amount = math.floor(math.max(0, amount))
  if self.cdata.wallet ~= amount then
    self.cdata.wallet = amount
    vRP:triggerEvent("playerMoneyUpdate", self)
    self:save()
  end

  return true
end

function Money.User:setBank(amount)
  if type(amount) ~= "number" then return false end

  amount = math.floor(math.max(0, amount))

  if self.cdata.bank ~= amount then
    self.cdata.bank = amount
    vRP:triggerEvent("playerMoneyUpdate", self)
    self:save()
  end

  return true
end

-- Convenience methods to add funds
function Money.User:giveWallet(amount)
  if type(amount) ~= "number" then return false end
  return self:setWallet(self:getWallet()+math.abs(amount))
end

function Money.User:giveBank(amount)
	if type(amount) ~= "number" then return false end
  return self:setBank(self:getBank()+math.abs(amount))
end

-- Payment operations with validations

-- Deduct from wallet if enough funds exist.
-- 'dry' mode allows checking without modifying data.
function Money.User:tryPayment(amount, dry)
	if type(amount) ~= "number" or amount < 0 then return false end
  if self:getWallet() >= amount then
    if not dry then
      self:setWallet(self:getWallet() - amount)
    end
    return true
  end
  return false
end

-- Withdraw from bank into wallet.
function Money.User:tryWithdraw(amount, dry)
	if type(amount) ~= "number" or amount <= 0 then return false end
  if self:getBank() >= amount then
    if not dry then
      self:setBank(self:getBank() - amount)
      self:giveWallet(amount)
    end
    return true
  end
  return false
end

-- Deposit funds from wallet into bank.
function Money.User:tryDeposit(amount, dry)
	if type(amount) ~= "number" or amount <= 0 then return false end
  if self:tryPayment(amount, dry) then
    if not dry then
      self:giveBank(amount)
    end
    return true
  end
  return false
end

-- Function to pay using card (deduct from bank only)
function Money.User:tryCardPayment(amount, dry)
	if type(amount) ~= "number" or amount <= 0 then return false end
  if self:getBank() >= amount then
    if not dry then
      self:setBank(self:getBank() - amount)
    end
    return true
  end
  return false
end

-- Try to cover payment using both wallet and bank if necessary.
function Money.User:tryFullPayment(amount, dry)
	if type(amount) ~= "number" or amount <= 0 then return false end
  local wallet = self:getWallet()
  if wallet >= amount then
    return self:tryPayment(amount, dry)
  else
    local remaining = amount - wallet
    if self:tryWithdraw(remaining, dry) then
      return self:tryPayment(amount, dry)
    end
  end
  return false
end

------------------------------------------------------------------
-- Module Initialization
------------------------------------------------------------------

function Money:__construct()
  vRP.Extension.__construct(self)
  self.cfg = module("vrp", "cfg/money")

  -- Main Menu Option (for user-to-user money giving)
	local function m_give(menu)
		local user = menu.user
		local remote = vRP.EXT.Base.remote

		local nplayer = remote.getNearestPlayer(user.source, 10)
		local nuser = vRP.users_by_source[nplayer]

		if not nplayer or not nuser or nuser.id == user.id then
			remote._notify(user.source, vRP.lang.common.no_player_near())
			return
		end

		local input = user:prompt(vRP.lang.money.give.prompt(), "")
		if not input or input == "" then return end

		local amount = tonumber(input)
		if not amount or amount <= 0 then
			remote._notify(user.source, vRP.lang.common.invalid_value())
			return
		end

		amount = math.floor(amount)

		if user:tryPayment(amount) then
			nuser:giveWallet(amount)
			remote._notify(user.source, vRP.lang.money.given({amount}))
			remote._notify(nuser.source, vRP.lang.money.received({amount}))
		else
			remote._notify(user.source, vRP.lang.money.not_enough())
		end
	end

	vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
		menu:addOption(vRP.lang.money.give.title(), m_give, vRP.lang.money.give.description())
	end)

  -- Admin Menu Option: Give Money to User
  local function m_givemoney(menu)
		local adminUser = menu.user
		local targetUser = vRP.users[menu.data.id]
		local remote = vRP.EXT.Base.remote

		if not targetUser then return end

		local input = adminUser:prompt(vRP.lang.admin.users.user.give_money.prompt(), "")
		if not input or input == "" then return end

		local amount = tonumber(input)
		if not amount or amount <= 0 then
			remote._notify(adminUser.source, vRP.lang.common.invalid_value())
			return
		end

		amount = math.floor(amount)
		targetUser:giveWallet(amount)

		remote._notify(adminUser.source, "You gave $" .. amount .. " to player ID " .. targetUser.id)
		remote._notify(targetUser.source, "You received $" .. amount .. " from an admin")
	end

	vRP.EXT.GUI:registerMenuBuilder("admin.users.user", function(menu)
		local adminUser = menu.user
		local targetUser = vRP.users[menu.data.id]

		if targetUser and adminUser:hasPermission("player.givemoney") then
			menu:addOption(vRP.lang.admin.users.user.give_money.title(), m_givemoney)
		end
	end)
end

------------------------------------------------------------------
-- Private Method
------------------------------------------------------------------

function Money:formatWallet(amount)
  local type = self.cfg.money_type or "USD"
  local symbol = self.cfg.currency_symbols[type] or ""
  return string.format('<span class="symbol">%s</span>%s', symbol, formatNumber(amount)) 
end

------------------------------------------------------------------
-- Event Handlers
------------------------------------------------------------------

Money.event = {}

function Money.event:characterLoad(user)
  if not user.cdata.wallet then
    user.cdata.wallet = self.cfg.open_wallet
  end

  if not user.cdata.bank then
    user.cdata.bank = self.cfg.open_bank
  end

  vRP:triggerEvent("playerMoneyUpdate", user)
end

function Money.event:playerSpawn(user, first_spawn)
  if self.cfg.money_display and first_spawn then
    vRP.EXT.GUI.remote._setDiv(user.source, "money", self.cfg.display_css, self:formatWallet(user:getWallet()))
  end
end

function Money.event:playerDeath(user)
  if self.cfg.lose_wallet_on_death then
    user:setWallet(0)
  end
end

function Money.event:playerMoneyUpdate(user)
  if not self.cfg.money_display then return end

  local currentWallet = tonumber(user:getWallet()) or 0
  vRP.EXT.GUI.remote._setDivContent(user.source, "money", self:formatWallet(currentWallet))

  if self.cfg.money_delta then
    if not user.lastWallet then
      user.lastWallet = currentWallet
      return
    end

    local delta = math.floor(currentWallet - user.lastWallet)
    if delta ~= 0 then
      local sign = delta > 0 and "+" or ""
			local color = (sign == "+") and self.cfg.delta_colors.positive or self.cfg.delta_colors.negative
			
			vRP.EXT.GUI.remote._setDiv(user.source, "delta", self.cfg.display_css, {sign .. delta})
			vRP.EXT.GUI.remote._setDivCss(user.source, "delta", ".div_delta{ color: ".. color .."; }")
			
      user.lastWallet = currentWallet
    end
  end
end

vRP:registerExtension(Money)
