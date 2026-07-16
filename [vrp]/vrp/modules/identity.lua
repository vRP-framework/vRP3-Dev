-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.identity then return end

-- this module describe the identity system

local htmlEntities = module("lib/htmlEntities")

local lang = vRP.lang

local Identity = class("Identity", vRP.Extension)

-- SUBCLASS

Identity.User = class("User")

-- STATIC

-- (ex: DDDLLL, D => digit, L => letter)
function Identity.generateStringNumber(format) 
  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  local number = ""
  for i=1,#format do
    local char = string.sub(format, i,i)
    if char == "D" then number = number..string.char(zbyte+math.random(0,9))
    elseif char == "L" then number = number..string.char(abyte+math.random(0,25))
    else number = number..char end
  end

  return number
end

-- PRIVATE METHODS

-- menu: cityhall
local function menu_cityhall(self)
  local function m_new_identity(menu)
    local user = menu.user

    local notify = vRP.EXT.Base.remote._notify
    local sanitize = sanitizeString
    local parse_int = parseInt
    local sconf = self.sanitizes.name
    local cost = self.new_identity_cost

    local firstname = user:prompt(lang.identity.cityhall.new_identity.prompt_firstname(), "") or ""
    firstname = sanitize(firstname, sconf[1], sconf[2])
    if string.len(firstname) < 2 or string.len(firstname) >= 50 then
      notify(user.source, lang.common.invalid_value())
      return
    end

    local name = user:prompt(lang.identity.cityhall.new_identity.prompt_name(), "") or ""
    name = sanitize(name, sconf[1], sconf[2])
    if string.len(name) < 2 or string.len(name) >= 50 then
      notify(user.source, lang.common.invalid_value())
      return
    end

    local age_raw = user:prompt(lang.identity.cityhall.new_identity.prompt_age(), "") or ""
    local age = parse_int(age_raw)
    if not age or age < 16 or age > 150 then
      notify(user.source, lang.common.invalid_value())
      return
    end

    if not user:tryPayment(cost) then
      notify(user.source, lang.money.not_enough())
      return
    end

    local registration = self:generateRegistrationNumber()
    local phone = self:generatePhoneNumber()

    user.identity.firstname = firstname
    user.identity.name = name
    user.identity.age = age
    user.identity.registration = registration
    user.identity.phone = phone

    vRP:execute("vRP/update_character_identity", {
      character_id = user.cid,
      firstname = firstname,
      name = name,
      age = age,
      registration = registration,
      phone = phone
    })

    vRP:triggerEvent("characterIdentityUpdate", user)
    notify(user.source, lang.money.paid({cost}))
  end

  vRP.EXT.GUI:registerMenuBuilder("cityhall", function(menu)
    menu.title = lang.identity.cityhall.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"

    menu:addOption(lang.identity.cityhall.new_identity.title(), m_new_identity, lang.identity.cityhall.new_identity.description({self.new_identity_cost}))
  end)
end

-- menu: identity
local function menu_identity(self)
  vRP.EXT.GUI:registerMenuBuilder("identity", function(menu)
    menu.title = lang.identity.title()
    menu.css.header_color="rgba(0,125,255,0.75)"

    local identity = self:getIdentity(menu.data.cid)

    if identity then
      menu:addOption(lang.identity.citizenship.title(), nil, lang.identity.citizenship.info({htmlEntities.encode(identity.name), htmlEntities.encode(identity.firstname), identity.age, identity.registration, identity.phone}))
    end
  end)
end

-- menu: admin users user
local function menu_admin_users_user(self)
  vRP.EXT.GUI:registerMenuBuilder("admin.users.user", function(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
			menu:addOption(lang.identity.title(), function(menu)
				local tuser = vRP.users[menu.data.id]

				if tuser and tuser:isReady() then
					menu.user:openMenu("identity", {cid = tuser.cid})
				end
			end)
    end
  end)
end

-- METHODS

function Identity:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/identity")
  self.sanitizes = module("cfg/sanitizes")

  -- in-memory maps to avoid frequent DB lookups
  self.reg_map = {}   -- registration -> cid
  self.phone_map = {} -- phone -> cid
  self.cid_reg = {}   -- cid -> registration
  self.cid_phone = {} -- cid -> phone

  -- menus
  menu_cityhall(self)
  menu_identity(self)
  menu_admin_users_user(self)

  -- add identity to main menu
  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
		menu:addOption(lang.identity.title(), function(menu)
			menu.user:openMenu("identity", {cid = menu.user.cid})
		end)
  end)

  -- copy small cfg pieces and avoid copying large name arrays to reduce memory
  if type(self.cfg) == "table" then
    self.phone_format = self.cfg.phone_format or "DDDDDDDDDD"
    self.city_hall = self.cfg.city_hall
    self.city_hall_map_entity = self.cfg.city_hall_map_entity
    self.new_identity_cost = self.cfg.new_identity_cost
    self.spawn_enabled = self.cfg.spawn_enabled
    self.spawn_position = self.cfg.spawn_position
    self.spawn_radius = self.cfg.spawn_radius
  end
  -- do not copy random_first_names/random_last_names here (lazy-loaded on demand)
  self.cfg = nil


  async(function()
    -- init sql
    vRP:prepare("vRP/identity_tables", [[
    CREATE TABLE IF NOT EXISTS vrp_character_identities(
      character_id INTEGER,
      registration VARCHAR(20),
      phone VARCHAR(20),
      firstname VARCHAR(50),
      name VARCHAR(50),
      age INTEGER,
      CONSTRAINT pk_character_identities PRIMARY KEY(character_id),
      CONSTRAINT fk_character_identities_characters FOREIGN KEY(character_id) REFERENCES vrp_characters(id) ON DELETE CASCADE,
      INDEX(registration),
      INDEX(phone)
    );
    ]])

    vRP:prepare("vRP/get_character_identity","SELECT * FROM vrp_character_identities WHERE character_id = @character_id")
    vRP:prepare("vRP/init_character_identity","INSERT IGNORE INTO vrp_character_identities(character_id,registration,phone,firstname,name,age) VALUES(@character_id,@registration,@phone,@firstname,@name,@age)")
    vRP:prepare("vRP/update_character_identity","UPDATE vrp_character_identities SET firstname = @firstname, name = @name, age = @age, registration = @registration, phone = @phone WHERE character_id = @character_id")
    vRP:prepare("vRP/get_characterbyreg","SELECT character_id FROM vrp_character_identities WHERE registration = @registration")
    vRP:prepare("vRP/get_characterbyphone","SELECT character_id FROM vrp_character_identities WHERE phone = @phone")

    vRP:execute("vRP/identity_tables")
  end)
end

-- identity access (online and offline characters)
-- return identity or nil
function Identity:getIdentity(cid)
  local user = vRP.users_by_cid[cid]
  if user then
    return user.identity
  else
    local rows = vRP:query("vRP/get_character_identity", {character_id = cid})
    return rows[1]
  end
end

-- return character_id or nil
function Identity:getByRegistration(registration)
  if not registration then return end

  -- check in-memory map first
  local cid = self.reg_map[registration]
  if cid then return cid end

  local rows = vRP:query("vRP/get_characterbyreg", {registration = registration or ""})
  if #rows > 0 then
    cid = rows[1].character_id
    self.reg_map[registration] = cid
    self.cid_reg[cid] = registration
    return cid
  end
end

-- return character_id or nil
function Identity:getByPhone(phone)
  if not phone then return end

  -- check in-memory map first
  local cid = self.phone_map[phone]
  if cid then return cid end

  local rows = vRP:query("vRP/get_characterbyphone", {phone = phone or ""})
  if #rows > 0 then
    cid = rows[1].character_id
    self.phone_map[phone] = cid
    self.cid_phone[cid] = phone
    return cid
  end
end

-- return a unique registration number
function Identity:generateRegistrationNumber()
  local character_id
  local registration = ""
  -- generate registration number
  repeat
    registration = Identity.generateStringNumber("DDDLLL")
    character_id = self:getByRegistration(registration)
  until not character_id

  return registration
end

-- return a unique phone number
function Identity:generatePhoneNumber()
  local character_id = nil
  local phone = ""

  -- generate phone number
  repeat
    phone = Identity.generateStringNumber(self.phone_format)
    character_id = self:getByPhone(phone)
  until not character_id

  return phone
end

-- EVENT

Identity.event = {}

function Identity.event:characterLoad(user)
  -- load identity
  local rows = vRP:query("vRP/get_character_identity", {character_id = user.cid})
  if #rows > 0 then -- loaded
    user.identity = rows[1]
  else -- create
    -- lazy-load name lists from config module to avoid retaining large arrays in the extension
    local idcfg = module("cfg/identity")
    local first_names = idcfg.random_first_names or {}
    local last_names = idcfg.random_last_names or {}
    user.identity = {
      registration = self:generateRegistrationNumber(),
      phone = self:generatePhoneNumber(),
      firstname = first_names[math.random(1, math.max(1,#first_names))],
      name = last_names[math.random(1, math.max(1,#last_names))],
      age = math.random(18,40)
    }

    vRP:execute("vRP/init_character_identity", {
      character_id = user.cid,
      registration = user.identity.registration,
      phone = user.identity.phone,
      firstname = user.identity.firstname,
      name = user.identity.name,
      age = user.identity.age
    })
  end

  -- populate in-memory maps for quick lookups
  if user.identity and user.identity.registration then
    self.reg_map[user.identity.registration] = user.cid
    self.cid_reg[user.cid] = user.identity.registration
  end
  if user.identity and user.identity.phone then
    self.phone_map[user.identity.phone] = user.cid
    self.cid_phone[user.cid] = user.identity.phone
  end

  vRP:triggerEvent("characterIdentityUpdate", user)
end

function Identity.event:characterUnload(user)
  -- cleanup in-memory maps for this character
  if not user then return end
  local cid = user.cid
  if not cid then return end

  local old_reg = self.cid_reg[cid]
  if old_reg then
    self.reg_map[old_reg] = nil
    self.cid_reg[cid] = nil
  end

  local old_phone = self.cid_phone[cid]
  if old_phone then
    self.phone_map[old_phone] = nil
    self.cid_phone[cid] = nil
  end
end

function Identity.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- send registration number to client at spawn
    self.remote._setRegistrationNumber(user.source, user.identity.registration)

    -- build city hall
    local menu
    local function enter(user)
      menu = user:openMenu("cityhall")
    end

    local function leave(user)
      user:closeMenu(menu)
    end

    local x,y,z = table.unpack(self.city_hall)

    local ment = clone(self.city_hall_map_entity)
    ment[2].title = lang.identity.cityhall.title()
    ment[2].pos = {x,y,z-1}
    vRP.EXT.Map.remote._addEntity(user.source,ment[1],ment[2])
    user:setArea("vRP:cityhall",x,y,z,1,1.5,enter,leave)
  end
end

function Identity.event:characterIdentityUpdate(user)
  -- update registration shown to client
  self.remote._setRegistrationNumber(user.source, user.identity.registration)

  -- update in-memory maps (keep reverse maps to remove old values)
  local old_reg = self.cid_reg[user.cid]
  if old_reg and old_reg ~= user.identity.registration then
    self.reg_map[old_reg] = nil
  end
  if user.identity.registration then
    self.reg_map[user.identity.registration] = user.cid
    self.cid_reg[user.cid] = user.identity.registration
  end

  local old_phone = self.cid_phone[user.cid]
  if old_phone and old_phone ~= user.identity.phone then
    self.phone_map[old_phone] = nil
  end
  if user.identity.phone then
    self.phone_map[user.identity.phone] = user.cid
    self.cid_phone[user.cid] = user.identity.phone
  end
end

vRP:registerExtension(Identity)