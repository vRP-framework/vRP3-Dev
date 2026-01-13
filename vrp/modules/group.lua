-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vRP/vRPShared.lua)

if not vRP.modules.group then return end

local lang = vRP.lang

-- This module defines the group/permission system (per character)
-- Multiple groups can be set to the same player, but the gtype config option can be used to set some groups as unique
local Group = class("Group", vRP.Extension)

-- SUBCLASS
Group.User = class("User")

-- Check if user has a specific group
function Group.User:hasGroup(name)
  return self.cdata.groups[name] ~= nil
end

-- Return map of groups
function Group.User:getGroups()
  return self.cdata.groups
end

-- Get the user's faction grade
function Group.User:getFactionGrade()
  return self.cdata.faction_grade
end

-- Get the user's current faction group
function Group.User:getFactionGroup()
  for group, _ in pairs(self.cdata.groups) do
    local cfg = vRP.EXT.Group.cfg.groups[group]
    if cfg and cfg._config and cfg._config.gtype == "faction" then
      return group
    end
  end
  return nil
end

-- Check if user is on faction duty
function Group.User:isOnFactionDuty()
  return self.cdata.faction_duty == 1
end

-- Set faction duty
function Group.User:setFactionDuty(state)
  local faction = self:getFactionGroup()
  if faction then
    self.cdata.faction_duty = state and 1 or 0
    if self.cdata.faction_duty == 1 then
      vRP.EXT.Base.remote._notify(self.source, "You are now ~g~On Duty~s~.")
    else
      vRP.EXT.Base.remote._notify(self.source, "You are now ~r~Off Duty~s~.")
    end
  end
end

function Group.User:addGroup(name)
  if self:hasGroup(name) then return end

  local groups = self:getGroups()
  local cfg = vRP.EXT.Group.cfg
  local ngroup = cfg.groups[name]
  if not ngroup then return end

  local gtype = ngroup._config and ngroup._config.gtype or nil

  -- Remove existing group with same gtype
  if gtype then
    for k in pairs(groups) do
      local kgroup = cfg.groups[k]
      if kgroup and kgroup._config and kgroup._config.gtype == gtype then
        self:removeGroup(k)
      end
    end
  end

  groups[name] = true

  if ngroup._config and ngroup._config.onjoin then
    ngroup._config.onjoin(self)
  end

  vRP:triggerEvent("playerJoinGroup", self, name, gtype)
end

function Group.User:removeGroup(name)
  local groups = self:getGroups()
  local cfg = vRP.EXT.Group.cfg
  local group = cfg.groups[name]

  local gtype = group and group._config and group._config.gtype

  if group and group._config and group._config.onleave then
    group._config.onleave(self)
  end

  groups[name] = nil

  -- Clear faction grade if it's a faction group
  if gtype == "faction" then
    self.cdata.faction_grade = nil
    self.cdata.faction_duty = 0
  end

  vRP:triggerEvent("playerLeaveGroup", self, name, gtype)
end
  
-- Get user group by type
-- Return group name or nil
function Group.User:getGroupByType(gtype)
  local groups = self:getGroups()
  local cfg = vRP.EXT.Group.cfg

  for k, v in pairs(groups) do
    local kgroup = cfg.groups[k]
    if kgroup then
      if kgroup._config and kgroup._config.gtype and kgroup._config.gtype == gtype then
        return k
      end
    end
  end
end

-- Check if the user has a specific permission
function Group.User:hasPermission(perm)
  local fchar = string.sub(perm, 1, 1)

  if fchar == "!" then -- Special function permission
    local _perm = string.sub(perm, 2, string.len(perm))
    local params = splitString(_perm, ".")
    if #params > 0 then
      local fperm = vRP.EXT.Group.func_perms[params[1]]
      if fperm then
        return fperm(self, params) or false
      else
        return false
      end
    end
  else -- Regular plain permission
    local cfg = vRP.EXT.Group.cfg
    local groups = self:getGroups()

    -- Precheck negative permission
    local nperm = "-"..perm
    for name in pairs(groups) do
      local group = cfg.groups[name]
      if group then
        for l, w in pairs(group) do -- For each group permission
          if l ~= "_config" and w == nperm then return false end
        end
      end
    end

    -- Check if the permission exists
    for name in pairs(groups) do
      local group = cfg.groups[name]
      if group then
        for l, w in pairs(group) do -- For each group permission
          if l ~= "_config" and w == perm then return true end
        end
      end
    end
  end

  return false
end

-- Check if the user has a specific list of permissions (all of them)
function Group.User:hasPermissions(perms)
  for _, perm in pairs(perms) do
    if not self:hasPermission(perm) then
      return false
    end
  end
  return true
end

-- PRIVATE METHODS

-- Menu: group_selector
local function menu_group_selector(self)
  local function m_select(menu, entry)
    local user = menu.user

    local group_name, grade
    if type(entry) == "table" and entry.group then
      group_name = entry.group
      grade = tonumber(entry.grade) -- Force to number
    else
      group_name = entry
    end

    if group_name then
      user:addGroup(group_name)

      -- If it's a faction, set default grade if provided
      local gcfg = vRP.EXT.Group.cfg.groups[group_name]
      if gcfg and gcfg._config and gcfg._config.gtype == "faction" and grade then
        user.cdata.faction_grade = grade -- Store as number
      end
    end

    user:closeMenu(menu)
  end

  vRP.EXT.GUI:registerMenuBuilder("group_selector", function(menu)
    menu.title = menu.data.name
    menu.css.header_color = "rgba(255,154,24,0.75)"

    for _, entry in ipairs(menu.data.groups or {}) do
      local group_name = type(entry) == "table" and entry.group or entry
      local title = self:getGroupTitle(group_name)

      if group_name and title then
        menu:addOption(title, m_select, nil, entry) 
      end
    end
  end)
end

-- Menu: admin users user
local function menu_user_groups(self)
  local function m_groups(menu, index)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    local groups_str = ""
    local cfg = vRP.EXT.Group.cfg

    if tuser and tuser:isReady() then
      for group in pairs(tuser.cdata.groups) do
        local group_name = group
        local grade_str = ""

        -- Check if group is a faction to add grade info
        local gcfg = cfg.groups[group]
        if gcfg and gcfg._config and gcfg._config.gtype == "faction" then
          local grade = tuser.cdata.faction_grade
          local grade_info = gcfg._config.grades[grade]
          if grade_info then
            grade_str = " ( " .. grade_info.name .. " )"
          end
        end

        groups_str = groups_str .. group_name .. grade_str .. "  "
      end
    end

    menu:updateOption(index, nil, lang.admin.users.user.groups.description({groups_str}))
  end

  local function m_addgroup(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      local group = user:prompt("Group name to add:", "")
      local cfg = vRP.EXT.Group.cfg
      local gcfg = cfg.groups[group]

      if gcfg and gcfg._config and gcfg._config.gtype == "faction" then
        local grades = gcfg._config.grades or {}
        local grade_list = {}

        for k, v in pairs(grades) do
          table.insert(grade_list, string.format("%d - %s", k, v.name or "Unnamed"))
        end

        table.sort(grade_list)

        local grade_prompt = "Available grades:\n" .. table.concat(grade_list, "\n")
        local grade = tonumber(user:prompt("Faction grade (number):", grade_prompt)) or 1
        tuser.cdata.faction_grade = grade
      end

      -- Remove existing faction if needed
      for k, v in pairs(tuser:getGroups()) do
        local g = cfg.groups[k]
        if g and g._config and g._config.gtype == "faction" then
          tuser:removeGroup(k)
        end
      end

      tuser:addGroup(group)
    end
  end

  local function m_removegroup(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      local group = user:prompt(lang.admin.users.user.group_remove.prompt(), "")
      tuser:removeGroup(group)
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("user.groups", function(menu)
    menu.title = "Groups"
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      menu:addOption(lang.admin.users.user.groups.title(), m_groups, lang.admin.users.user.groups.description())
      if user:hasPermission("player.group.add") then
        menu:addOption(lang.admin.users.user.group_add.title(), m_addgroup)
      end
      if user:hasPermission("player.group.remove") then
        menu:addOption(lang.admin.users.user.group_remove.title(), m_removegroup)
      end
    end
  end)
end

-- Menu: manage_faction
local function menu_manage_faction(self)
  -- Check if user has Lider or Co_Lider
  local function has_leader_permissions(user, faction_cfg, grade)
    local grade_cfg = faction_cfg._config.grades[grade]
    return grade_cfg and (grade_cfg.Lider or grade_cfg.Co_Lider)
  end

  -- Get grade config
  local function get_grade_cfg(faction_cfg, grade)
    return faction_cfg._config.grades[grade]
  end

  -- Add a nearby player to faction
  local function m_add_player_in_faction(menu)
    local user = menu.user
    local near_player = vRP.EXT.Base.remote.getNearestPlayer(user.source, 10)

    if not near_player then
      vRP.EXT.Base.remote._notify(user.source, "No player nearby")
      return
    end

    local nuser = vRP.users_by_source[near_player]
    if not nuser or nuser:getFactionGroup() then
      vRP.EXT.Base.remote._notify(user.source, "Player is already in a faction")
      return
    end

    local faction = user:getFactionGroup()
    local grade = user:getFactionGrade()
    local faction_cfg = vRP.EXT.Group.cfg.groups[faction]

    if has_leader_permissions(user, faction_cfg, grade) then
      local confirm = user:request("Do you want to add " .. nuser.name .. " to your faction?", 30)
      if confirm then
        nuser:addGroup(faction)
        vRP.EXT.Base.remote._notify(user.source, "Added " .. nuser.name .. " to the faction")
        vRP.EXT.Base.remote._notify(nuser.source, "You were added to the faction")
      end
    else
      vRP.EXT.Base.remote._notify(user.source, "You don't have permission to add members")
    end
  end

  -- Remove a faction member
  local function m_remove_player_in_faction(menu)
    local user = menu.user
    local faction = user:getFactionGroup()
    local grade = user:getFactionGrade()
    local faction_cfg = vRP.EXT.Group.cfg.groups[faction]

    if not has_leader_permissions(user, faction_cfg, grade) then
      vRP.EXT.Base.remote._notify(user.source, "You don't have permission to remove members")
      return
    end

    vRP.EXT.GUI:registerMenuBuilder("faction_members", function(submenu)
      submenu.title = "Faction Members"
      submenu.css.header_color = "rgba(0,125,255,0.75)"

      for _, target in pairs(vRP.users) do
        if target:isReady() and target:getFactionGroup() == faction then
          if target.id ~= user.id then -- Can't remove yourself
            if not get_grade_cfg(faction_cfg, grade).Co_Lider or target:getFactionGrade() < grade then
              submenu:addOption(target.name, function()
                local confirm = user:request("Do you want to remove " .. target.name .. " from the faction?", 30)
                if confirm then
                  target:removeGroup(faction)
                  vRP.EXT.Base.remote._notify(user.source, "Removed " .. target.name)
                  vRP.EXT.Base.remote._notify(target.source, "You were removed from the faction")
                  user:closeMenu(submenu)
                end
              end)
            end
          end
        end
      end
    end)

    user:openMenu("faction_members")
  end

  -- Check if user can modify target's grade
  local function can_modify_grade(user_grade_cfg, user_grade, target_grade, is_self)
    -- Lider can't modify other Liders or themselves
    if user_grade_cfg.Lider then
      if is_self then return false end
      return target_grade < user_grade
    end

    -- Co-Lider can modify lower grades
    if user_grade_cfg.Co_Lider then
      return target_grade < user_grade
    end

    return false
  end

  -- Grades management menu
  vRP.EXT.GUI:registerMenuBuilder("faction_grades", function(menu)
    local user = menu.user
    local faction = user:getFactionGroup()
    local user_grade = user:getFactionGrade()
    local faction_cfg = vRP.EXT.Group.cfg.groups[faction]

    menu.title = "Manage Grades"
    menu.css.header_color = "rgba(0,125,255,0.75)"

    local user_grade_cfg = get_grade_cfg(faction_cfg, user_grade)
    if not user_grade_cfg.Lider and not user_grade_cfg.Co_Lider then
      vRP.EXT.Base.remote._notify(user.source, "You don't have permission to manage grades")
      return
    end

    -- Populate member list
    for _, target in pairs(vRP.users) do
      if target:isReady() and target:getFactionGroup() == faction then
        local target_grade = target:getFactionGrade()
        local is_self = (target == user)
        
        if can_modify_grade(user_grade_cfg, user_grade, target_grade, is_self) then
          local target_grade_name = get_grade_cfg(faction_cfg, target_grade).name 
          
          menu:addOption(target.name .. " - " .. target_grade_name, function()
            vRP.EXT.GUI:registerMenuBuilder("faction_grade_selector", function(grade_menu)
              grade_menu.title = "Grade " .. target.name
              grade_menu.css.header_color = "rgba(0,125,255,0.75)"

              local max_grade = user_grade_cfg.Lider 
                and #faction_cfg._config.grades 
                or (user_grade - 1)

              for g = 0, max_grade do
                local ginfo = faction_cfg._config.grades[g]
                if ginfo then
                  grade_menu:addOption(ginfo.name, function()
                    local confirm = user:request("Set " .. target.name .. " to " .. ginfo.name .. "?", 30)
                    if confirm then
                      target.cdata.faction_grade = g
                      vRP.EXT.Base.remote._notify(user.source, "Set " .. target.name .. " to " .. ginfo.name)
                      vRP.EXT.Base.remote._notify(target.source, "Your rank changed to " .. ginfo.name)
                      user:closeMenu(grade_menu)
                    end
                  end)
                end
              end
            end)
            user:openMenu("faction_grade_selector")
          end)
        end
      end
    end
  end)

  -- Open grades management menu
  local function m_manage_grades(menu)
    local user = menu.user
    local faction = user:getFactionGroup()
    local grade = user:getFactionGrade()
    local faction_cfg = vRP.EXT.Group.cfg.groups[faction]

    local user_grade_cfg = get_grade_cfg(faction_cfg, grade)
    if not user_grade_cfg.Lider and not user_grade_cfg.Co_Lider then
      vRP.EXT.Base.remote._notify(user.source, "You don't have permission to manage grades")
      return
    end

    user:openMenu("faction_grades")
  end

  -- Exit faction
  local function m_exit_faction(menu)
    local user = menu.user
    local faction = user:getFactionGroup()
    local grade = user:getFactionGrade()
    local faction_cfg = vRP.EXT.Group.cfg.groups[faction]
    local grade_cfg = get_grade_cfg(faction_cfg, grade)

    if not grade_cfg.Lider then
      local confirm = user:request("Do you want to leave the faction?", 30)
      if confirm then
        user:removeGroup(faction)
        user.cdata.faction_grade = nil
        vRP.EXT.Base.remote._notify(user.source, "You left the faction")
        user:closeMenu(menu)
      end
    end
  end

  -- Toggle duty status
  local function m_toggle_duty(menu)
    local user = menu.user
    user:setFactionDuty(not user:isOnFactionDuty())
  end

  -- Main faction menu
  vRP.EXT.GUI:registerMenuBuilder("manage_faction", function(menu)
    local user = menu.user
    local faction = user:getFactionGroup()
    local grade = user:getFactionGrade()
    local faction_cfg = vRP.EXT.Group.cfg.groups[faction]
    local grade_cfg = get_grade_cfg(faction_cfg, grade)

    menu.title = "Faction"
    menu.css.header_color = "rgba(0,125,255,0.75)"

    if grade_cfg.Lider or grade_cfg.Co_Lider then
      menu:addOption("Add Member", m_add_player_in_faction)
      menu:addOption("Remove Member", m_remove_player_in_faction)
      menu:addOption("Grades", m_manage_grades)
    end

    menu:addOption("Toggle Duty", m_toggle_duty)

    if not grade_cfg.Lider then
      menu:addOption("Exit Faction", m_exit_faction)
    end
  end)
end

function Group:taskPaycheck()
  for faction_name, group_cfg in pairs(self.cfg.groups) do
    if group_cfg._config and group_cfg._config.gtype == "faction" then
      local interval = group_cfg._config.paycheck_interval or 60
      self.paychecks_elapsed[faction_name] = (self.paychecks_elapsed[faction_name] or 0) + 1

      if self.paychecks_elapsed[faction_name] >= interval then
        self.paychecks_elapsed[faction_name] = 0

        local users = self:getUsersByGroup(faction_name)
        for _, user in pairs(users) do
          if user:isReady() and user.spawns > 0 and user:isOnFactionDuty() then
            local grade = user:getFactionGrade()
            local grade_cfg = group_cfg._config.grades and group_cfg._config.grades[grade]

            if grade_cfg and grade_cfg.payment and grade_cfg.payment > 0 then
              user:giveWallet(grade_cfg.payment)
              vRP.EXT.Base.remote._notify(user.source, "Faction salary: ~g~$" .. grade_cfg.payment)
            end
          end
        end
      end
    end
  end
end


-- METHODS

function Group:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/groups")
  self.func_perms = {}
  self.paychecks_elapsed = {} -- faction name => elapsed minutes

  -- register not fperm (negate another fperm)
  self:registerPermissionFunction("not", function(user, params)
    return not user:hasPermission("!"..table.concat(params, ".", 2))
  end)

  -- register group fperm
  self:registerPermissionFunction("group", function(user, params)
    local group = params[2]
    if group then
      return user:hasGroup(group)
    end
    return false
  end)

  -- Faction menu access
  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    local user = menu.user
    if user:getFactionGroup() then
      menu:addOption("Faction", function()
        user:openMenu("manage_faction")
      end)
    end
  end)

  -- menu
  menu_group_selector(self)
  menu_user_groups(self)
  menu_manage_faction(self)

  -- main menu
  vRP.EXT.GUI:registerMenuBuilder("admin.users.user", function(menu)
    menu:addOption("Groups", function(menu)
      menu.user:openMenu("user.groups", menu.data)
    end)
  end)

  local function task_paycheck()
    SetTimeout(60000, task_paycheck)
    self:taskPaycheck()
  end

  async(function()
    task_paycheck()
  end)
end


-- return users list
function Group:getUsersByGroup(name)
  local users = {}

  for _,user in pairs(vRP.users) do
    if user:isReady() and user:hasGroup(name) then 
      table.insert(users, user) 
    end
  end

  return users
end

-- return users list
function Group:getUsersByPermission(perm)
  local users = {}

  for _,user in pairs(vRP.users) do
    if user:isReady() and user:hasPermission(perm) then 
      table.insert(users, user) 
    end
  end

  return users
end

-- return title or nil
function Group:getGroupTitle(group_name)
  local group = self.cfg.groups[group_name]
  if group and group._config then
    return group._config.title
  end
end

-- register a special permission function
-- name: name of the permission -> "!name.[...]"
-- callback(user, params) 
--- params: params (strings) of the permissions, ex "!name.param1.param2" -> ["name", "param1", "param2"]
--- should return true or false/nil
function Group:registerPermissionFunction(name, callback)
  if self.func_perms[name] then
    self:log("WARNING: re-registered permission function \""..name.."\"")
  end
  self.func_perms[name] = callback
end

-- EVENT

Group.event = {}

function Group.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- Initialize group selectors
    for k, v in pairs(self.cfg.selectors or {}) do
      local gcfg = v._config

      if gcfg then
        local x, y, z = gcfg.x, gcfg.y, gcfg.z
        local menu

        local function enter(user)
          if user:hasPermissions(gcfg.permissions or {}) then
            local player_hours = user.cdata.hours or 0
            local can_access = true

            -- Check required hours for each group
            for _, group_name in ipairs(v) do
              local group_cfg = self.cfg.groups and self.cfg.groups[group_name]
              local required_hours = group_cfg and group_cfg._config and group_cfg._config.required_hours or 0

              if vRP.modules.hours and required_hours > 0 and player_hours < required_hours then
                vRP.EXT.Base.remote._notify(user.source, "You need ~r~" .. (required_hours - player_hours) .. " ~w~ more hours to access " .. group_name .. "!")
                can_access = false
              end
            end

            -- Open menu if all groups pass the check
            if can_access then
              menu = user:openMenu("group_selector", { name = k, groups = v })
            end
          end
        end

        local function leave(user)
          if menu then
            user:closeMenu(menu)
          end
        end

        local ment = clone(gcfg.map_entity or {})
        ment[2] = ment[2] or {}
        ment[2].title = k
        ment[2].pos = { x, y, z - 1 }
        vRP.EXT.Map.remote._addEntity(user.source, ment[1] or "default", ment[2])

        user:setArea("vRP:gselector:" .. k, x, y, z, 1, 1.5, enter, leave)
      end
    end

    -- Optional: Setup group count display
    if next(self.cfg.count_display_permissions or {}) and self.cfg.display then
      vRP.EXT.GUI.remote.setDiv(user.source, "group_count_display", self.cfg.count_display_css or "", "")
    end
  end

  -- Call group onspawn callbacks
  local groups = user:getGroups() or {}
  for name in pairs(groups) do
    local group = self.cfg.groups and self.cfg.groups[name]
    if group and group._config and group._config.onspawn then
      group._config.onspawn(user)
    end
  end
end

function Group.event:characterLoad(user)
  if not user.cdata.groups then -- init groups table
    user.cdata.groups = {}
  end

  -- add config user forced groups
  local groups = self.cfg.users[user.id]
  if groups then
    for _,group in ipairs(groups) do
      user:addGroup(group)
    end
  end

  -- add default groups
  for _, group in ipairs(self.cfg.default_groups) do
    user:addGroup(group)
  end
end

vRP:registerExtension(Group)