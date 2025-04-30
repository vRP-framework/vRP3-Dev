function Clothing(Framework)
  local self = {}
  self.__name = "Clothing"
	Framework.Modules(self)

  self.Player = function()
    return {
      __construct = function(self)
  			Framework.Modules(self)
        function self:setCloak(cloak)
          if not self.cData.pre_cloak then
            self.cData.pre_cloak = self.remote.Clothing.getCustomization(self.source)
          else
            self.remote.Clothing.setCustomization(self.source, self.cData.pre_cloak)
          end
          self.remote.Clothing._setCustomization(self.source, cloak)
        end

        function self:removeCloak()
          if self.cData.pre_cloak then
            self.remote.Clothing._setCustomization(self.source, self.cData.pre_cloak)
            self.cData.pre_cloak = nil
          end
        end

				function self:save()
					local clothes = self.remote.Clothing.getCustomization(self.source)
					if clothes then
						self.cData['clothes'] = clothes
					end
					print(json.encode(self.cData.clothes)..'\n'..json.encode(self.cData))
				end
      end
    }
  end

	function self:__construct()
		RegisterCommand("cloakplayer", function(source)
			local cloak = {
				model = "mp_m_freemode_01",
				["drawable:11"] = {5, 0},
				["drawable:8"] = {15, 0},
				["drawable:4"] = {10, 0},
				["drawable:6"] = {1, 0},
				["prop:0"] = {-1, 0}
			}

			local player = Framework.players[source]
			if player then
				player:setCloak(cloak)
			end
		end)
	end

  return self
end

Framework:RegisterModule(Clothing)
