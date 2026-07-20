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

    self.owners[id] = { owner_cid = user.cid, purchased_at = os.time() }
    save_owner(self, id)

    vRP.EXT.Base.remote._notify(user.source, lang.business.buy.purchased({bcfg.title}))
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
    elseif owner.owner_cid == user.cid then
      menu:addOption(lang.business.manage.title(), nil, lang.business.manage.info({bcfg.title, owner.purchased_at}))
      -- future: pricing/stock/income options for this business's `kind`
      -- get appended here without restructuring this builder
    else
      local identity = vRP.EXT.Identity and vRP.EXT.Identity:getIdentity(owner.owner_cid)
      local name = (identity and (identity.firstname or "").." "..(identity.name or "")) or "someone"
      menu:addOption(lang.business.owned_by({name}), nil, "")
    end

    if owner and user:hasPermission("admin.business") then
      menu:addOption(lang.business.admin.revoke_title(), m_admin_revoke, lang.business.admin.revoke_description(), id)
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

-- EVENT

Business.event = {}

function Business.event:playerSpawn(user, first_spawn)
  if not self._owners_hydrated then pcall(function() self:hydrateOwners() end) end
  if first_spawn then
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
