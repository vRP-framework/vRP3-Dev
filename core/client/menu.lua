function Menu(Framework)
  local self = {}
	self.__name = "Menu"
	self.tunnel = {}
	Framework.Modules(self)

  local menus = {}
  local currentMenu = nil

  function self:create(name, title)
    local menu = {
      name = name,
      title = title or "Menu",
      options = {}
    }
    menus[name] = menu
		print('created ',name)
    return menu
  end

  function self:addOption(menu, label, description, func)
    table.insert(menu.options, {label = label, description = description, func = func})
  end

  function self:getData(menu)
    local options = {}
    for index, opt in ipairs(menu.options) do
      table.insert(options, {opt.label, opt.description, index})
    end
    return {
      title = menu.title,
      options = options,
      select_event = true
    }
  end

	function self:getMenu(menu)
		if menus[menu] then
			return menus[menu]
		end
	end

  function self:open(name)
    local menu = menus[name]
    if menu then
      currentMenu = name
    	SetNuiFocus(false, false)
      SendNUIMessage({
        act = "open_menu",
        menudata = self:getData(menu)
      })
    else
      print("Menu not found:", name)
    end
  end

  function self:close()
    SetNuiFocus(false, false)
    SendNUIMessage({ act = "close_menu" })
    currentMenu = nil
  end

  function self:select(index)
    if currentMenu then
      local menu = menus[currentMenu]
      if menu and menu.options[index] and type(menu.options[index].func) == "function" then
        menu.options[index].func()
      else
        print("No function attached to selected option.")
      end
    end
  end

	function self:__construct()
		self:create('main', "Main Menu")

		RegisterCommand('menu_up', function()
			if currentMenu then 
				SendNUIMessage({ act = "key", key = "UP" }) 
			else
				self:open('main')
			end
		end, false)

		RegisterCommand('menu_down', function()
			if currentMenu then SendNUIMessage({ act = "key", key = "DOWN" }) end
		end, false)

		RegisterCommand('menu_select', function()
			if currentMenu then SendNUIMessage({ act = "key", key = "RIGHT" }) end
		end, false)

		RegisterCommand('menu_cancel', function()
			if currentMenu then self:close() end
		end, false)

		-- Bind the commands to default keys
		RegisterKeyMapping('menu_up', 'Open Menu/Menu Up', 'keyboard', 'UP')
		RegisterKeyMapping('menu_down', 'Menu Down', 'keyboard', 'DOWN')
		RegisterKeyMapping('menu_select', 'Menu Select', 'keyboard', 'RIGHT')
		RegisterKeyMapping('menu_cancel', 'Menu Cancel', 'keyboard', 'MOUSE_RIGHT')
		--------------------
		RegisterNUICallback('menu', function(data, cb)
			if data.act == "valid" then
				self:select(data.option + 1)
			end

			cb('ok')
		end)
	end

  return self
end

Framework:RegisterModule(Menu)