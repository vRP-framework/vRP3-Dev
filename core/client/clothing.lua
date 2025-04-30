function Clothing(Framework)
  local self = {}
  self.__name = "Clothing"
	Framework.Modules(self)
  self.tunnel = {}
	self.mp_models = {
		[GetHashKey("mp_m_freemode_01")] = true,
		[GetHashKey("mp_f_freemode_01")] = true
	}
	local clothingIndexes = {
		hat = 0,
		shirt = 0,
		pants = 0,
		shoes = 0,
		accessory = 0,
	}

	function self:ChangeClothing(type, change)
		local ped = PlayerPedId()

		clothingIndexes[type] = clothingIndexes[type] + change
		if clothingIndexes[type] < 0 then clothingIndexes[type] = 0 end
		-- No upper limit yet (can be added later)
		if type == "hat" then
			SetPedPropIndex(ped, 0, clothingIndexes[type], 0, true)
		elseif type == "shirt" then
			SetPedComponentVariation(ped, 11, clothingIndexes[type], 0, 2)
		elseif type == "pants" then
			SetPedComponentVariation(ped, 4, clothingIndexes[type], 0, 2)
		elseif type == "shoes" then
			SetPedComponentVariation(ped, 6, clothingIndexes[type], 0, 2)
		elseif type == "accessory" then
			SetPedComponentVariation(ped, 7, clothingIndexes[type], 0, 2)
		end
  end

	function self:openClothing()
		if self.modules.Menu then
			self.modules.Menu:open('clothing')
		end
	end
	local function clothingmenu(self)
	end
	function self:__construct()
		local Menu = Framework.modules.Menu
		local clothingMenu = Menu:create('clothing', 'Clothing Menu')
		----------------
		local hatsMenu = Menu:create('hats', "Clothing - Hats")
		Menu:addOption(clothingMenu, 'Hats', 'Adjust your hat', function() Menu:open('hats') end)
		Menu:addOption(hatsMenu, 'Previous menu', 'Return to previous menu.', function() Menu:open('clothing') end)
		Menu:addOption(hatsMenu, 'Previous Hat', 'Go to previous hat', function() self:ChangeClothing('hat', -1) end)
		Menu:addOption(hatsMenu, 'Next Hat', 'Go to next hat', function() self:ChangeClothing('hat', 1) end)
		------
		local shirts = Menu:create('Shirts', "Clothing - Shirts")
		Menu:addOption(clothingMenu, 'Shirts', 'Change Shirts', function() Menu:open('Shirts') end)
		Menu:addOption(shirts, 'Previous menu', 'Return to previous menu.', function() Menu:open('clothing') end)
		Menu:addOption(shirts, 'Previous Hat', 'Go to previous shirt', function() self:ChangeClothing('shirt', -1) end)
		Menu:addOption(shirts, 'Next Hat', 'Go to next shirt', function() self:ChangeClothing('shirt', 1) end)
		------
		RegisterCommand('openclothes', function() Menu:open('clothing') end,false)
		RegisterKeyMapping('openclothes', 'Opens clothing menu','keyboard', 'F6')
	end

	self.tunnel.getDrawables = self.getDrawables
	self.tunnel.getDrawableTextures = self.getDrawableTextures
	self.tunnel.getCustomization = self.getCustomization
	self.tunnel.setCustomization = self.setCustomization
  return self
end

Framework:RegisterModule(Clothing)
