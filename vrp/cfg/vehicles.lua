local cfg = {}

cfg.vehicle_update_interval = 15 -- seconds
cfg.vehicle_check_interval = 15 -- seconds, re-own/respawn task


-- list of all purchasable vehicles
-- model       = spawn code
-- name        = display name
-- price       = purchase price
-- category    = as per GetVehicleClass() (see FiveM docs)
-- type        = as per IsThisModelACar()/IsThisModelABike(), etc.
-- shop        = single shop key or array of shop keys
cfg.vehicles = {
    { model = 'alpha',           name = 'Alpha',                                  price = 53000,   category = 'sports',         type = 'automobile', shop = 'pdm' },
    { model = 'banshee',         name = 'Banshee',                              price = 56000,   category = 'sports',         type = 'automobile', shop = 'pdm' },
    { model = 'bestiagts',       name = 'Bestia GTS',                             price = 37000,   category = 'sports',         type = 'automobile', shop = 'pdm' },
    { model = 'buffalo',         name = 'Buffalo',                             price = 18750,   category = 'sports',         type = 'automobile', shop = 'pdm' },
    { model = 'buffalo2',        name = 'Buffalo S',                              price = 24500,   category = 'sports',         type = 'automobile', shop = 'pdm' },
    { model = 'carbonizzare',    name = 'Carbonizzare',                  brand = 'Grotti',          price = 155000,  category = 'sports',         type = 'automobile', shop = 'pdm' },
    { model = 'comet2',          name = 'Comet',                         brand = 'Pfister',         price = 130000,  category = 'sports',         type = 'automobile', shop = 'pdm' },
    { model = 'comet3',          name = 'Comet Retro Custom',            brand = 'Pfister',         price = 175000,  category = 'sports',         type = 'automobile', shop = 'pdm' },
    { model = 'comet4',          name = 'Comet Safari',                  brand = 'Pfister',         price = 110000,  category = 'sports',         type = 'automobile', shop = 'pdm' },
    { model = 'comet5',          name = 'Comet SR',                      brand = 'Pfister',         price = 155000,  category = 'sports',         type = 'automobile', shop = 'pdm' },
    { model = 'coquette',        name = 'Coquette',                      brand = 'Invetero',        price = 145000,  category = 'sports',         type = 'automobile', shop = 'pdm' },



  { model = "blista",   name = "Blista",          price = 100,   category =  "compacts",   type = "automobile", shop = {"pdm","luxury"} },
  { model = "buzzard",  name = "Buzzard Attack",  price = 100,   category =  "helicopter", type = "aircraft",   shop = "aircraft" },
  { model = "dinghy",   name = "Dinghy",          price = 100,   category =  "boats",      type = "boat",       shop = "marina" }
  -- add your own entries below
}

-- configuration for each vehicle shop
-- key = shop identifier (matches cfg.vehicles.shop)
-- showroom_location = vec3(x,y,z)
-- preview            = vec4(x,y,z,heading)
-- purchaseSpawn      = vec4(x,y,z,heading)
-- blip               = { id = blipId, color = blipColor }
-- marker             = { id = markerId, scale = { x,y,z }, color = { r,g,b,a } }
cfg.vehicleshops = {
    pdm = {
      shop_name         = "Luxury Car Dealership",
      showroom_location = vec3(-54.94, -1111.50, 26.44),
      preview           = vec4(-60.0, -1110.0, 26.4, 120.0),
      purchaseSpawn = {
          vec4(-61.744976043701,-1117.8952636719,26.432458877563, 10), -- Location where purchased vehicles will spawn
          vec4(-56.407440185547,-1116.4392089844,26.434999465942, 10)

      },
      blip              = { id = 326, color = 69 },
      marker            = { id = 1, scale = {1.5,1.5,1.0}, color = {255,215,0,100} }
    },
    aircraft = {
      shop_name         = "LSIA Hangar",
      showroom_location = vec3(-970.63586425781,-2999.8103027344,13.945083618164),
      preview           = vec4(-1345.1208496094,-2722.6687011719,13.944955825806, 330.0),
      purchaseSpawn = {
          vec4(-979.73876953125,-2997.0693359375,13.945078849792,0), -- x,y,z,heading
          vec4(-974.91973876953,-2986.9838867188,13.945068359375, 0),
          vec4(-984.21917724609,-3004.3366699219,13.945056915283,0)
      },
      blip              = { id = 90, color = 38 },
      marker            = { id = 1, scale = {2.0,2.0,1.0}, color = {0,191,255,120} }
    }
  }

-- where players can sell back vehicles
cfg.sellvehicle = {
    cars = {
      name = "Sell Cars",  
      type = "automobile",
      sellPrice = 75, -- players get 75% of original price
      blip = { id = 369, color = 25 },
      marker = { id = 1, scale = {1.5, 1.5, 1.0}, color = {0, 128, 255, 100} },
      coords = {
        vec3(-61.744976043701,-1117.8952636719,26.432458877563)
      }
    },
  
    aircraft = {
      name = "Sell Aircraft",  
      type = "aircraft",  
      sellPrice = 50, -- players get 50% of original price
      blip = { id = 370, color = 38 },
      marker = { id = 1, scale = {2.0, 2.0, 1.0}, color = {0, 191, 255, 120} },
      coords = {
        vec3(-965.33026123047,-3004.2521972656,13.9426612854)
      }
    }
  }

return cfg
