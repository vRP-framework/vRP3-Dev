-- init vRP server context
Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

local cvRP = module("vrp", "client/vRP")
vRP = cvRP()

local pvRP = {}
-- load script in vRP context
pvRP.loadScript = module
Proxy.addInterface("vRP", pvRP)

local cfg = module("vrp_multiCharacter", "cfg/multiCharacter")
local Multi = class("Multi_Character", vRP.Extension)

Multi.event = {}

function Multi:__construct()
  vRP.Extension.__construct(self)

  self.charSelect = false
  self.char = nil
  self.visible = false
  self.delay = 0

  Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
      if self.charSelect then
        for k,v in pairs(cfg.disable_keys) do
          DisableControlAction(0, v, display)
        end
      end
		end
	end)

  Citizen.CreateThread(function()
    Citizen.Wait(500)
		if not GetIsLoadingScreenActive() and not cfg.loading then
			self:intiSkyCam()
		end
	end)


  -- Callbacks
  RegisterNUICallback("createNewCharacter", function(data)
    self.remote._createCharacter(data)
  end)

  RegisterNUICallback("close", function(data)
    Multi:close()
  end)

  RegisterNUICallback("selectCharacter", function(data)
    self.charSelect = true
    self.remote._selectCharacter(data)

    self:toggleVisibility(false)  -- Set visibility to true (invisible) on character select
  end)

  RegisterNUICallback("selectLocation", function(data)
    local x,y,z,w = data.coords.x, data.coords.y,data.coords.z, data.coords.w
    
    --vRP:log("Selected location: "..json.encode(data.coords))
    --self:moveCamera(x,y,z,w)
  end)

  RegisterNUICallback("deselectCharacter", function(data)
    self.charSelect = false
    self:toggleVisibility(true)  -- Set visibility to false (visible) on character deselect
  end)

  RegisterNUICallback("playCharacter", function(data)
    self:destroyCam()

    -- we need this to be as early as possible, without it being TOO early, it's a gamble!
    self:intiSkyCam()

    self.remote._getLocations()
  end)

  RegisterNUICallback("playLocation", function(data)
    local x,y,z,w = data.x,data.y,data.z,data.w
    self:destroyCam()
    self:close()

    SetFocusPosAndVel(x+0.0001, y+0.0001, z+0.0001, 0.0, 0.0, 0.0)

    -- Set the entity coordinates (without the heading)
    SetEntityCoords(GetPlayerPed(-1), x+0.0001, y+0.0001, z+0.0001, 1,0,0,1)

    -- Set the entity heading (using the w component)
    SetEntityHeading(GetPlayerPed(-1), w)

    self:spawnPlayer()

    Citizen.Wait(self.delay)

    FreezeEntityPosition(GetPlayerPed(-1), false)

  end)

  RegisterNUICallback("deleteCharacter", function(data)
    self.remote._deleteCharacter(data)
  end)
end 

function Multi:toggleSound(state)
  if state then
    StartAudioScene("MP_LEADERBOARD_SCENE");
  else
    StopAudioScene("MP_LEADERBOARD_SCENE");
  end
end

function Multi:intiSkyCam()
  -- Disable sound (if configured)
  self:toggleSound(cfg.sound)

  -- Switch out the player if it isn't already in a switch state.
  if not IsPlayerSwitchInProgress() then
    SwitchOutPlayer(PlayerPedId(), 0, 1)
  end
end

-- Hide radar & HUD, set cloud opacity, and use a hacky way of removing third party resource HUD elements.
function Multi:clearScreen()
  SetCloudHatOpacity(cloudOpacity)
  HideHudAndRadarThisFrame()
  
  -- nice hack to 'hide' HUD elements from other resources/scripts. kinda buggy though.
  SetDrawOrigin(0.0, 0.0, 0.0, 0)
end

function Multi:pointCamAtChar()
  local coords = GetEntityCoords(GetPlayerPed(-1))
  local forward = GetEntityForwardVector(GetPlayerPed(-1))
  local camCoords = coords + forward * 1.75
  local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

  SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z + 0.25)
  RenderScriptCams(true, false, 0, true, true)
  PointCamAtEntity(cam, GetPlayerPed(-1), 0.0, 0.0, 0.1, true)
end

function Multi:destroyCam()
  DestroyCam("DEFAULT_SCRIPTED_CAMERA", false)
  RenderScriptCams(false, false, 0, true, true)
end

-- If state is true (selected), we make the character invisible.
-- If state is false (deselected), we make the character visible.
function Multi:toggleVisibility(state)
  self.visible = state

  self.char = GetPlayerPed(-1)
  
  if not state then
    Citizen.Wait(200)
  end
  
  SetEntityCollision(self.char, not self.visible, not self.visible)
  SetEntityInvincible(self.char, self.visible)
  SetEntityVisible(self.char, not self.visible, false)
end

function Multi:spawnPlayer(multiplyer)
  Citizen.CreateThread(function()
    -- Set the delay to 4 seconds by default, or multiplyer * 1000
    self.delay = multiplyer and 1000 * multiplyer or 4000

    -- Initialize the sky cam
    self:intiSkyCam()

    -- Wait for the camera switch state to be 'waiting' (5)
    while GetPlayerSwitchState() ~= 5 do
      Citizen.Wait(0)
    end

    self:clearScreen() -- Clear the screen and fade out immediately
    DoScreenFadeOut(0)
    Citizen.Wait(0)

    DoScreenFadeIn(500) -- Fade in the screen over 500 ms

    self:toggleSound(false) -- Re-enable the sound in case it was muted

    local timer = GetGameTimer()

    while true do -- Main loop to switch to the player after 4 seconds
      Citizen.Wait(0) -- Ensure the thread yields control
      
      if GetGameTimer() - timer > self.delay then
        self:clearScreen()

        SwitchInPlayer(PlayerPedId()) -- Switch to the player

        -- Wait for the player switch to be completed (state 12)
        while GetPlayerSwitchState() ~= 12 do
          Citizen.Wait(0)
        end

        break -- Stop the loop
      end
    end

    -- Reset the draw origin to ensure HUD elements reappear correctly
    ClearDrawOrigin()
  end)
end

function Multi:open(delay)
  -- Set delay based on input, defaulting to 0 if invalid
  self.delay = (type(delay) == "number" and delay > 0) and (delay * 1000) or 0
  self.charSelect = not self.charSelect

  -- Make the character selection invisible
  self:toggleVisibility(true)

  -- Get default location and apply a slight offset
  local x, y, z = table.unpack(cfg.default_location)
  local playerPed = GetPlayerPed(-1)
  
  -- Set focus and entity position with slight offset
  SetFocusPosAndVel(x + 0.0001, y + 0.0001, z + 0.0001, 0.0, 0.0, 0.0)
  SetEntityCoords(playerPed, x + 0.0001, y + 0.0001, z + 0.0001, true, false, false, true)
  SetEntityHeading(playerPed, cfg.heading)
  FreezeEntityPosition(playerPed, true)

  -- Disable loading screens immediately
  ShutdownLoadingScreen()
  ShutdownLoadingScreenNui()

  Citizen.CreateThread(function()
    Citizen.Wait(self.delay)  -- Initial delay

    SwitchInPlayer(playerPed)  -- Switch player context

    -- Wait for player switch completion (state 12)
    while self.delay > 0 and GetPlayerSwitchState() ~= 12 do
      Citizen.Wait(0)  -- Yield until conditions are met
    end

    if not cfg.loading then
      Citizen.Wait(6000)  -- Additional wait if loading was specified
    end
    
    DoScreenFadeIn(500)  -- Fade in smoothly
    SendNUIMessage({ type = "open" })  -- Notify NUI to open
    SetNuiFocus(true, true)  -- Set focus to the NUI
  end)

  -- Point camera at character
  self:pointCamAtChar()
  --DoScreenFadeIn(500)  -- Fade in smoothly
  self.remote.getCharacters(source)  -- Fetch characters from server
end


function Multi:close()
  self.charSelect = not self.charSelect
  SetNuiFocus(false, false)

  Citizen.Wait(1000)

  SendNUIMessage({type = "close"})

  self:toggleVisibility(false)
end

function Multi:updateChars(data)
  SendNUIMessage({type = "charData", charData = data})
end

function Multi:updateLocations(data)
  SendNUIMessage({type = "locData", locData = data})
end

Multi.tunnel = {}

Multi.tunnel.open = Multi.open
Multi.tunnel.close = Multi.close
Multi.tunnel.updateChars = Multi.updateChars
Multi.tunnel.updateLocations = Multi.updateLocations
Multi.tunnel.pedGender = Multi.pedGender
Multi.tunnel.setGender = Multi.setGender
Multi.tunnel.intiSkyCam = Multi.intiSkyCam
Multi.tunnel.spawnPlayer = Multi.spawnPlayer

vRP:registerExtension(Multi)