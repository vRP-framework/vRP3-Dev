-- Bootstraps this resource's own client vRP instance -- see
-- vrp_template/client.lua for details.
vRP = module("vrp", "client/bootstrap")

local cfg = module("vrp_loadscreen", "cfg/cfg")

local LoadScreen = class("LoadScreen", vRP.Extension)
LoadScreen.tunnel = {}

function LoadScreen:__construct()
  vRP.Extension.__construct(self)

  self.closed = false

  -- FiveM's own native "the ped exists" signal. Confirmed reliable in this
  -- framework -- vRP's own client/base.lua hooks this exact same native
  -- event to drive its own client-side playerSpawn dispatch and the
  -- server-side character-ready flow this resource's close() waits on, so
  -- it's guaranteed to fire, not a maybe. Used here to make the ped
  -- invisible/unattackable as early as possible (ShutdownLoadingScreen
  -- itself is called later, in close(), not here -- see the comment there
  -- for why), and also forwarded to the NUI as its own message -- this
  -- fires once real connecting/building is actually done (the ped can't
  -- exist until it is), well before vRP's own separate ~2s-later
  -- readiness check, so it's a more precise "native loading is done"
  -- signal than the NUI guessing from a script-loading percentage.
  AddEventHandler('playerSpawned', function()
    local ped = PlayerPedId()
    SetEntityVisible(ped, false, false)
    SetEntityInvincible(ped, true)
    SetPlayerInvincible(PlayerId(), true)

    SendLoadingScreenMessage(json.encode({ eventName = "vrpNativeReady" }))
  end)

  self:sendInit()
  self:pollPlayerCount()
end

-- The loading screen's own NUI page may not have finished registering its
-- message listener the instant this resource starts, so resend a couple of
-- times early on rather than risk a lost first message. Handling vrpInit
-- more than once is harmless on the JS side.
function LoadScreen:sendInit()
  local payload = json.encode({
    eventName = "vrpInit",
    serverName = cfg.server_name,
    defaultTheme = cfg.default_theme,
    tips = cfg.tips,
    rules = cfg.rules,
    keybinds = cfg.keybinds,
    keybindsPerSlide = cfg.keybinds_per_slide,
    audio = cfg.audio,
    -- purely cosmetic -- lets the NUI's simulated Initializing/Getting
    -- Character Data fills match how long close() actually waits; Lua
    -- still owns the real timing regardless of what the NUI displays.
    initializingMs = cfg.initializing_duration_ms,
    characterDataMs = cfg.character_data_duration_ms
  })

  SendLoadingScreenMessage(payload)
  SetTimeout(300, function() SendLoadingScreenMessage(payload) end)
  SetTimeout(1200, function() SendLoadingScreenMessage(payload) end)
end

function LoadScreen:pollPlayerCount()
  Citizen.CreateThread(function()
    while not self.closed do
      local ok, info = pcall(function() return self.remote.getPlayerCount() end)
      if ok and info then
        SendLoadingScreenMessage(json.encode({
          eventName = "vrpPlayerCount",
          count = info.count,
          max = info.max
        }))
      end
      Citizen.Wait(5000)
    end
  end)
end

-- TUNNEL: called by the server once vRP confirms the character is ready.
-- Everything from here is a plain Lua timer chain rather than relying on
-- the NUI calling back into Lua (RegisterNUICallback support for the
-- special "loadingScreen" frame specifically isn't something documented/
-- verified, unlike SendLoadingScreenMessage/ShutdownLoadingScreenNui,
-- which are the confirmed manual-shutdown natives) -- this is what
-- actually closes things, the NUI side just reacts to messages.
function LoadScreen:close()
  self.closed = true
  SendLoadingScreenMessage(json.encode({ eventName = "vrpClose" }))

  -- Extra fixed safety buffer after vRP itself says ready -- "Initializing"
  -- on screen, purely a margin to smooth over any straggling client-side
  -- setup, not tied to any real loading signal.
  SetTimeout(cfg.initializing_duration_ms, function()
    -- This same message serves two purposes on the NUI side depending on
    -- what it's already showing: normally "Loading Server Data..." has
    -- already started earlier (via vrpClose, once vRP itself is ready),
    -- and this is what promotes that into the final "Loading Character
    -- Data..." step; if that earlier trigger never fired for some reason,
    -- this is the fallback that starts Loading Server Data instead. Not
    -- tied to any real loading signal either way.
    SendLoadingScreenMessage(json.encode({ eventName = "vrpCharacterData" }))

    -- Screen stays open cfg.character_data_extra_ms past when that step
    -- visually finishes, so it never disappears right as it hits 100%.
    SetTimeout(cfg.character_data_duration_ms + cfg.character_data_extra_ms, function()
      SendLoadingScreenMessage(json.encode({ eventName = "vrpFadeOut" }))

      -- Let the fade-overlay CSS transition actually play before the NUI
      -- frame disappears out from under it.
      SetTimeout(cfg.close_fade_ms, function()
        local ped = PlayerPedId()
        SetEntityVisible(ped, true, false)
        SetEntityInvincible(ped, false)
        SetPlayerInvincible(PlayerId(), false)

        -- ShutdownLoadingScreen (background rendering handoff) called
        -- here, right before ShutdownLoadingScreenNui, rather than early
        -- on playerSpawned -- matches the reference vrp_loading
        -- resource's exact ordering (its close() does the same thing
        -- back-to-back). That resource's audio never cuts out; ours,
        -- calling this same native early and then keeping the NUI (and
        -- its audio) alive for several more seconds afterward, does.
        -- Calling it here means our NUI's audio only has to survive up
        -- to this single moment too, same as theirs, instead of
        -- surviving several extra seconds past whatever this native's
        -- transition disrupts.
        pcall(ShutdownLoadingScreen)
        pcall(ShutdownLoadingScreenNui)
      end)
    end)
  end)
end
LoadScreen.tunnel.close = LoadScreen.close

vRP:registerExtension(LoadScreen)
