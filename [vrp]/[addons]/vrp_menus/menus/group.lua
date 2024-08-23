-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
local init = module("vrp_menus", "cfg/components")
if not init.group then return end

local lang = vRP.lang
local Group = class("Group", vRP.Component)

-- menu: group_selector
local function menu_group_selector(self)
  local function m_select(menu, group_name)
    local user = menu.user

    user:addGroup(group_name)
    user:closeMenu(menu)
  end

  vRP.EXT.GUI:registerMenuBuilder("group_selector", function(menu)
    menu.title = menu.data.name
    menu.css.header_color = "rgba(255,154,24,0.75)"

    for k,group_name in pairs(menu.data.groups) do
      if k ~= "_config" then
        local title = self:getGroupTitle(group_name)
        if title then
          menu:addOption(title, m_select, nil, group_name)
        end
      end
    end
  end)
end

-- menu: admin users user
local function menu_user_groups(self)
  local function m_groups(menu, index)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    local groups = ""
    if tuser and tuser:isReady() then
      for group in pairs(tuser.cdata.groups) do
        groups = groups..group.." "
      end
    end

    menu:updateOption(index, nil, lang.admin.users.user.groups.description({groups}))
  end

  local function m_addgroup(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      local group = user:prompt(lang.admin.users.user.group_add.prompt(),"")
      tuser:addGroup(group)
    end
  end

  local function m_removegroup(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      local group = user:prompt(lang.admin.users.user.group_remove.prompt(),"")
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

function Group:__construct()
  vRP.Component.__construct(self)

  -- menu
  menu_group_selector(self)
  menu_user_groups(self)
  
  -- main menu
  vRP.EXT.GUI:registerMenuBuilder("admin.users.user", function(menu)
    menu:addOption("Groups", function(menu)
      menu.user:openMenu("user.groups", menu.data)
    end)
  end)
end

vRP:registerComponent(Group)