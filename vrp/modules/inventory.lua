-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.inventory then return end

local htmlEntities = module("vrp", "lib/htmlEntities")

local lang = vRP.lang

-- this module define the player inventory
local Inventory = class("Inventory", vRP.Extension)

-- SUBCLASS

Inventory.User = class("User")

-- return map of fullid => amount
function Inventory.User:getInventory()
  return self.cdata.inventory
end

-- try to give an item
-- dry: if passed/true, will not affect
-- return true on success or false
function Inventory.User:tryGiveItem(fullid, amount, dry, no_notify)
    if amount <= 0 then return false end
    if not self.cdata.inventory then return false end

    local inventory = self:getInventory()
    local citem = vRP.EXT.Inventory:computeItem(fullid)
    if not citem then return false end

    local new_weight = self:getInventoryWeight() + citem.weight * amount
    if new_weight > self:getInventoryMaxWeight() then return false end

    if not dry then
        inventory[fullid] = (inventory[fullid] or 0) + amount
        if not no_notify then
            vRP.EXT.Base.remote._notify(self.source, lang.inventory.give.received({citem.name, amount}))
        end
    end
    return true
end

-- try to take an item from inventory
-- dry: if passed/true, will not affect
-- return true on success or false
function Inventory.User:tryTakeItem(fullid, amount, dry, no_notify)
  if amount <= 0 then return false end
  if not self.cdata.inventory then return false end

  local inventory = self:getInventory()
  local current = inventory[fullid] or 0

  local bag_type = self.cdata.bag
local item_base = vRP.EXT.Inventory:parseItem(fullid)[1]

-- prevent removing equipped bag item
if bag_type and item_base == bag_type then
  if not no_notify then
    vRP.EXT.Base.remote._notify(self.source, "You can't remove your currently equipped bag.")
  end
  return false
end


  if current < amount then
    if not dry and not no_notify then
      local citem = vRP.EXT.Inventory:computeItem(fullid)
      if citem then
        vRP.EXT.Base.remote._notify(self.source, lang.inventory.missing({citem.name, amount - current}))
      end
    end
    return false
  end

  if not dry then
    local new_amount = current - amount
    if new_amount > 0 then
      inventory[fullid] = new_amount
    else
      inventory[fullid] = nil
    end

    if not no_notify then
      local citem = vRP.EXT.Inventory:computeItem(fullid)
      if citem then
        vRP.EXT.Base.remote._notify(self.source, lang.inventory.give.given({citem.name, amount}))
      end
    end
  end

  return true
end

-- get item amount in the inventory
function Inventory.User:getItemAmount(fullid)
  local inventory = self:getInventory()
  return inventory[fullid] or 0
end

-- return inventory total weight
function Inventory.User:getInventoryWeight()
  return vRP.EXT.Inventory:computeItemsWeight(self:getInventory())
end

-- Updated User methods without Aptitude references
function Inventory.User:getMaxWeightWithoutBag()
  local base = vRP.EXT.Inventory.cfg.inventory_base_strength
  local per_level = vRP.EXT.Inventory.cfg.inventory_weight_per_strength
  return base + per_level -- Removed level calculation
end

function Inventory.User:getInventoryMaxWeight()
  local base = vRP.EXT.Inventory.cfg.inventory_base_strength
  local per_level = vRP.EXT.Inventory.cfg.inventory_weight_per_strength
  local bag_bonus = 0

  local bag_type = self.cdata.bag
  local bag_data = vRP.EXT.Inventory.cfg.bags[bag_type ]
  if bag_data then
    bag_bonus = bag_data.bonus
  end

  return base + per_level + bag_bonus -- Removed level-based calculation
end

-- Updated bag toggle function
function Inventory.User:buildBagToggleOption(bag_type, menu)
  local user = menu.user
  local current_bag = user.cdata.bag

  local function toggle()
    if current_bag == bag_type then
      -- Attempt to unequip bag
      local max_without_bag = user:getMaxWeightWithoutBag()
      local current_weight = user:getInventoryWeight()
      
      if current_weight > max_without_bag then
        vRP.EXT.Base.remote._notify(user.source, "Your inventory is too heavy to remove the bag.")
        return
      end

      user.cdata.bag = nil
      vRP.EXT.Base.remote._notify(user.source, "You removed your bag.")
    else
      -- Equip new bag (replacing current one)
      user.cdata.bag = bag_type
      vRP.EXT.Base.remote._notify(user.source, "You equipped a " .. bag_type .. " bag.")
    end

    user:actualizeMenu()
  end

  local text = (current_bag == bag_type) and "Unequip Bag" or "Equip Bag"
  menu:addOption("Toggle ("..text..")", toggle, "Equip or unequip this bag.")
end

function Inventory.User:clearInventory()
  self.cdata.inventory = {}
end

-- chest menu remove event
local function e_chest_remove(menu)
  -- unload chest

  if menu.data.cb_close then
    menu.data.cb_close(menu.data.id)
  end

  vRP.EXT.Inventory:unloadChest(menu.data.id)
end

-- open a chest by identifier (GData)
-- cb_close(id): called when the chest is closed (optional)
-- cb_in(chest_id, fullid, amount): called when an item is added (optional)
-- cb_out(chest_id, fullid, amount): called when an item is taken (optional)
-- return chest menu or nil
function Inventory.User:openChest(id, max_weight, cb_close, cb_in, cb_out)
  if not vRP.EXT.Inventory.chests[id] then -- not already loaded
    local chest = vRP.EXT.Inventory:loadChest(id)
    local menu = self:openMenu("chest", {id = id, chest = chest, max_weight = max_weight, cb_close = cb_close, cb_in = cb_in, cb_out = cb_out})

    menu:listen("remove", e_chest_remove)

    return menu
  else
    vRP.EXT.Base.remote._notify(self.source, lang.inventory.chest.already_opened())
  end
end

-- STATIC

-- PRIVATE METHODS

-- menu: inventory item
local function menu_inventory_item(self)
  -- give action
  local function m_give(menu)
    local user = menu.user
    local fullid = menu.data.fullid
    local citem = self:computeItem(fullid)

    -- get nearest player
    local nuser
    local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source, 10)
    if nplayer then nuser = vRP.users_by_source[nplayer] end

    if nuser then
      -- prompt number
      local amount = parseInt(user:prompt(lang.inventory.give.prompt({user:getItemAmount(fullid)}),""))

      if nuser:tryGiveItem(fullid,amount,true) then
        if user:tryTakeItem(fullid,amount,true) then
          user:tryTakeItem(fullid, amount)
          nuser:tryGiveItem(fullid, amount)

          if user:getItemAmount(fullid) > 0 then
            user:actualizeMenu()
          else
            user:closeMenu(menu)
          end

          vRP.EXT.Base.remote._playAnim(user.source,true,{{"mp_common","givetake1_a",1}},false)
          vRP.EXT.Base.remote._playAnim(nuser.source,true,{{"mp_common","givetake2_a",1}},false)
        else
          vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
        end
      else
        vRP.EXT.Base.remote._notify(user.source,lang.inventory.full())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
    end
  end

  -- trash action
  local function m_trash(menu)
    local user = menu.user
    local fullid = menu.data.fullid
    local citem = self:computeItem(fullid)

    -- prompt number
    local amount = parseInt(user:prompt(lang.inventory.trash.prompt({user:getItemAmount(fullid)}),""))
    if user:tryTakeItem(fullid,amount,nil,true) then
      if user:getItemAmount(fullid) > 0 then
        user:actualizeMenu()
      else
        user:closeMenu(menu)
      end

      vRP.EXT.Base.remote._notify(user.source,lang.inventory.trash.done({citem.name,amount}))
      vRP.EXT.Base.remote._playAnim(user.source,true,{{"pickup_object","pickup_low",1}},false)
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("inventory.item", function(menu)
    menu.css.header_color="rgba(0,125,255,0.75)"

    local user = menu.user
    local citem = self:computeItem(menu.data.fullid)
    if citem then
      menu.title = htmlEntities.encode(citem.name.." ("..user:getItemAmount(menu.data.fullid)..")")
    end

    -- item menu builder
if citem.menu_builder then
  citem.menu_builder(citem.args, menu)
end

-- add toggle bag option if this is a bag
local item_base = self:parseItem(menu.data.fullid)[1]
if self.cfg.bags[item_base] then
  menu.user:buildBagToggleOption(item_base, menu)
end


    -- add give/trash options
    menu:addOption(lang.inventory.give.title(), m_give, lang.inventory.give.description())
    menu:addOption(lang.inventory.trash.title(), m_trash, lang.inventory.trash.description())
  end)
end

-- menu: inventory
local function menu_inventory(self)
  local function m_item(menu, value)
    menu.user:openMenu("inventory.item", {fullid = value})
  end
  vRP.EXT.GUI:registerMenuBuilder("inventory", function(menu)
    menu.title = lang.inventory.title()
    menu.css.header_color="rgba(0,125,255,0.75)"

    local user = menu.user
    local unit = self.cfg.inventory_unit -- Get unit from config

    -- Inventory weight progress
    local weight = user:getInventoryWeight()
    local max_weight = user:getInventoryMaxWeight()
    local weight_str = string.format("%.2f %s", weight, unit)
    local max_weight_str = string.format("%.2f %s", max_weight, unit)
    
    local hue = math.floor(math.max(125*(1-weight/max_weight), 0))
    menu:addOption(
      "<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight)..
      "\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>", 
      nil, 
      lang.inventory.info_weight({weight_str, max_weight_str}) -- Add unit to weight info
    )

    -- Inventory items
    for fullid, amount in pairs(user:getInventory()) do 
      local citem = self:computeItem(fullid)
      if citem then
        local item_weight = string.format("%.2f %s", citem.weight, unit) -- Add unit to item weight
        menu:addOption(
          htmlEntities.encode(citem.name), 
          m_item, 
          lang.inventory.iteminfo({amount, citem.description, item_weight}), 
          fullid
        )
      end
    end
  end)
end

-- CHEST TAKE MENU
local function menu_chest_take(self)
  local function m_take(menu, fullid)
  end
  vRP.EXT.GUI:registerMenuBuilder("chest.take", function(menu)
    local unit = self.cfg.inventory_unit -- Get unit from config
    
    -- Chest weight info
    local weight = self:computeItemsWeight(menu.data.chest)
    local max_weight = menu.data.max_weight
    local weight_str = string.format("%.2f %s", weight, unit)
    local max_weight_str = string.format("%.2f %s", max_weight, unit)
    
    menu:addOption(
      "<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight)..
      "\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>", 
      nil, 
      lang.inventory.info_weight({weight_str, max_weight_str}) -- Add unit
    )

    -- Chest items
    for fullid,amount in pairs(menu.data.chest) do
      local citem = self:computeItem(fullid)
      local item_weight = string.format("%.2f %s", citem.weight, unit) -- Add unit
      menu:addOption(
        htmlEntities.encode(citem.name), 
        m_take, 
        lang.inventory.iteminfo({amount, citem.description, item_weight}), 
        fullid
      )
    end
  end)
end

-- CHEST PUT MENU
local function menu_chest_put(self)
  local function m_put(menu, fullid)
  end

  vRP.EXT.GUI:registerMenuBuilder("chest.put", function(menu)
    local unit = self.cfg.inventory_unit 
    
    -- Player weight info
    local weight = menu.user:getInventoryWeight()
    local max_weight = menu.user:getInventoryMaxWeight()
    local weight_str = string.format("%.2f %s", weight, unit)
    local max_weight_str = string.format("%.2f %s", max_weight, unit)
    
    menu:addOption(
      "<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight)..
      "\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>", 
      nil, 
      lang.inventory.info_weight({weight_str, max_weight_str}) -- Add unit
    )

    -- Player items
    for fullid,amount in pairs(menu.user:getInventory()) do
      local citem = self:computeItem(fullid)
      if citem then
        local item_weight = string.format("%.2f %s", citem.weight, unit) -- Add unit
        menu:addOption(
          htmlEntities.encode(citem.name), 
          m_put, 
          lang.inventory.iteminfo({amount, citem.description, item_weight}), 
          fullid
        )
      end
    end
  end)
end

  vRP.EXT.GUI:registerMenuBuilder("chest.put", function(menu)
    menu.title = lang.inventory.chest.put.title()
    menu.css.header_color = "rgba(0,255,125,0.75)"

    -- add weight info
    local weight = menu.user:getInventoryWeight()
    local max_weight = menu.user:getInventoryMaxWeight()
    local hue = math.floor(math.max(125*(1-weight/max_weight), 0))
    menu:addOption("<div class=\"dprogressbar\" data-value=\""..string.format("%.2f",weight/max_weight).."\" data-color=\"hsl("..hue..",100%,50%)\" data-bgcolor=\"hsl("..hue..",100%,25%)\" style=\"height: 12px; border: 3px solid black;\"></div>", nil, lang.inventory.info_weight({string.format("%.2f",weight),max_weight}))

    -- add user items
    for fullid,amount in pairs(menu.user:getInventory()) do
      local citem = self:computeItem(fullid)
      if citem then
        menu:addOption(htmlEntities.encode(citem.name), m_put, lang.inventory.iteminfo({amount,citem.description,string.format("%.2f", citem.weight)}), fullid)
      end
    end
  end)

-- menu: chest
local function menu_chest(self)
  local function m_take(menu)
    local smenu = menu.user:openMenu("chest.take", menu.data) -- pass menu chest data
    menu:listen("remove", function(menu)
      menu.user:closeMenu(smenu)
    end)
  end

  local function m_put(menu)
    local smenu = menu.user:openMenu("chest.put", menu.data) -- pass menu chest data
    menu:listen("remove", function(menu)
      menu.user:closeMenu(smenu)
    end)
  end

  vRP.EXT.GUI:registerMenuBuilder("chest", function(menu)
    menu.title = lang.inventory.chest.title()
    menu.css.header_color="rgba(0,255,125,0.75)"

    menu:addOption(lang.inventory.chest.take.title(), m_take)
    menu:addOption(lang.inventory.chest.put.title(), m_put)
  end)
end

-- menu: admin users user
local function menu_admin_users_user(self)
  local function m_giveitem(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      local fullid = user:prompt(lang.admin.users.user.give_item.prompt(),"")
      local amount = parseInt(user:prompt(lang.admin.users.user.give_item.prompt_amount(),""))
      if not tuser:tryGiveItem(fullid, amount) then
        vRP.EXT.Base.remote._notify(user.source, lang.admin.users.user.give_item.notify_failed())
      end
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("admin.users.user", function(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      if user:hasPermission("player.giveitem") then
        menu:addOption(lang.admin.users.user.give_item.title(), m_giveitem)
      end
    end
  end)
end
  local function m_take(menu)
  end
  local function m_take(menu)
  end
  local function m_take(menu)
  end
-- METHODS

function Inventory:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/inventory")

  self.items = {} -- item definitions
  self.computed_items = {} -- computed item definitions
  self.chests = {} -- loaded chests

  self:defineItem("Large_bag","Large bag","Add 25 kg",nil,1)
  self:defineItem("Medium_bag","Medium bag","Add 20 kg",nil,1)
  self:defineItem("Small_bag","Small bag","Add 15 kg",nil,1)



  -- special item permission
  local function fperm_item(user, params)
    if #params == 3 then -- decompose item.operator
      local item = params[2]
      local op = params[3]

      local amount = user:getItemAmount(item)

      local fop = string.sub(op,1,1)
      if fop == "<" then  -- less (item.<x)
        local n = parseInt(string.sub(op,2,string.len(op)))
        if amount < n then return true end
      elseif fop == ">" then -- greater (item.>x)
        local n = parseInt(string.sub(op,2,string.len(op)))
        if amount > n then return true end
      else -- equal (item.x)
        local n = parseInt(string.sub(op,1,string.len(op)))
        if amount == n then return true end
      end
    end
  end

  vRP.EXT.Group:registerPermissionFunction("item", fperm_item)

  -- menu

  menu_inventory_item(self)
  menu_inventory(self)
  menu_chest(self)
  menu_chest_take(self)
  menu_chest_put(self)
  menu_admin_users_user(self)

  local function m_inventory(menu)
    menu.user:openMenu("inventory")
  end

  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    menu:addOption(lang.inventory.title(), m_inventory, lang.inventory.description())
  end)

  -- define config items
  local cfg_items = module("cfg/items")
  for id,v in pairs(cfg_items.items) do
    self:defineItem(id,v[1],v[2],v[3],v[4])
  end
end

-- define an inventory item (parametric or plain text data)
-- id: unique item identifier (string, no "." or "|")
-- name: display name, value or genfunction(args)
-- description: value or genfunction(args) (html)
-- menu_builder: (optional) genfunction(args, menu)
-- weight: (optional) value or genfunction(args)
--
-- genfunction are functions returning a correct value as: function(args, ...)
-- where args is a list of {base_idname,args...}
function Inventory:defineItem(id,name,description,menu_builder,weight)
  if self.items[id] then
    self:log("WARNING: re-defined item \""..id.."\"")
  end

  self.items[id] = {name=name,description=description,menu_builder=menu_builder,weight=weight}
end


function Inventory:parseItem(fullid)
  return splitString(fullid,"|")
end

-- compute item definition (cached)
-- return computed item or nil
-- computed item {}
--- name
--- description
--- weight
--- menu_builder: can be nil
--- args: parametric args
function Inventory:computeItem(fullid)
  local citem = self.computed_items[fullid]

  if not citem then -- compute
    local args = self:parseItem(fullid)
    local item = self.items[args[1]]
    if item then
      -- name
      local name
      if type(item.name) == "string" then
        name = item.name
      elseif item.name then
        name = item.name(args)
      end

      if not name then name = fullid end

      -- description
      local desc
      if type(item.description) == "string" then
        desc = item.description
      elseif item.description then
        desc = item.description(args)
      end

      if not desc then desc = "" end

      -- weight
      local weight
      if type(item.weight) == "number" then
        weight = item.weight
      elseif item.weight then
        weight = item.weight(args)
      end

      if not weight then weight = 0 end

      citem = {name=name, description=desc, weight=weight, menu_builder = item.menu_builder, args = args}
      self.computed_items[fullid] = citem
    end
  end

  return citem
end

-- compute weight of a list of items (in inventory/chest format)
function Inventory:computeItemsWeight(items)
  local weight = 0

  for fullid, amount in pairs(items) do
    local citem = self:computeItem(fullid)
    weight = weight+(citem and citem.weight or 0)*amount
  end

  return weight
end

-- load global chest
-- id: identifier (string)
-- return chest (as inventory, map of fullid => amount)
function Inventory:loadChest(id)
  local chest = self.chests[id]
  if not chest then
    local sdata = vRP:getGData("vRP:chest:"..id)
    if sdata and string.len(sdata) > 0 then
      chest = msgpack.unpack(sdata)
    end

    if not chest then chest = {} end

    self.chests[id] = chest
  end

  return chest
end

-- unload global chest
-- id: identifier (string)
function Inventory:unloadChest(id)
  local chest = self.chests[id]
  if chest then
    vRP:setGData("vRP:chest:"..id, msgpack.pack(chest))
    self.chests[id] = nil
  end
end

-- EVENT
Inventory.event = {}

function Inventory.event:characterLoad(user)
  if not user.cdata.inventory then
    user.cdata.inventory = {}
  end
  if not user.cdata.bag then
    user.cdata.bag = nil
  end
end


function Inventory.event:playerDeath(user)
  if self.cfg.lose_inventory_on_death then
    local new_inventory = {}

    -- preserve only items listed in keep_items_on_death
    if self.cfg.keep_items_on_death and type(self.cfg.keep_items_on_death) == "table" then
      for fullid, amount in pairs(user:getInventory()) do
        local base_id = vRP.EXT.Inventory:parseItem(fullid)[1]
        for _, keep_id in ipairs(self.cfg.keep_items_on_death) do
          if base_id == keep_id then
            new_inventory[fullid] = amount
            break
          end
        end
      end
    end

    user.cdata.inventory = new_inventory
  end
end


function Inventory.event:playerSpawn(user, first_spawn)
  if first_spawn then
    for chest_id, chest_data in pairs(self.cfg.chests or {}) do
      local coords = chest_data.coords
      local title = chest_data.title
      local weight = chest_data.weight
      local permissions = chest_data.permission or {}

      if coords then
        local menu
        local function enter(user)
          if user:hasPermissions(permissions) then
            menu = user:openChest("cfg_chest:" .. chest_id, weight)
          end
        end

        local function leave(user)
          if menu then
            user:closeMenu(menu)
          end
        end

        -- Set map marker
        local ment = {"PoI",{title = title,pos = {coords.x, coords.y, coords.z - 1}}}

        vRP.EXT.Map.remote._addEntity(user.source, ment[1], ment[2])

        -- Define interaction area
        user:setArea("vRP:cfg_chest:" .. chest_id, coords.x, coords.y, coords.z, 1.0, 1.5, enter, leave)
      end
    end
  end
end


vRP:registerExtension(Inventory)