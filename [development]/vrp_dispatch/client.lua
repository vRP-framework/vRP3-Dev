Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

local cvRP = module("vrp", "client/vRP")
vRP = cvRP()

local pvRP = {}

function pvRP.loadScript(resource, path)
  module(resource, path)
end

Proxy.addInterface("vRP", pvRP)

local Dispatch = class("Dispatch", vRP.Extension)
local cfg = module("vrp_dispatch", "cfg/cfg")

function Dispatch:__construct()
  vRP.Extension.__construct(self)

  CreateThread(function()
    print("Starting delay...")
    Wait(10000) -- Wait for 10000 milliseconds (10 seconds)
    self:secretKey(cfg.openAIApiKey)
  end)
end

function Dispatch:secretKey(key)
  print("[RADIO] Received secret key, sending to NUI")
  SendNuiMessage(json.encode({
    type      = "radioConfig",
    openaiKey = key
  }))
end

-- Displays dispatch text.
function Dispatch:radio(msg)
  print("[RADIO] " .. tostring(msg))
end

function Dispatch:radioDev()
  print("[RADIO DEV] This is a test radio message from the server.")
  SendNuiMessage(json.encode({ type = "DEV" }))

  SetNuiFocus(true, true)
end

function Dispatch:playRadioMessage(data)
  if not data then return false end

  print("[RADIO] Playing radio message:")
  print("Text: " .. tostring(data.text))

  SendNUIMessage(json.encode({
    type     = "radioMessage",
    text     = data.text,
    voice    = data.voice    or "onyx",
    callsign = data.callsign or "Dispatch",
    speed    = data.speed    or 1.0
  }))

  return true
end


Dispatch.tunnel = {}
Dispatch.tunnel.radio = Dispatch.radio
Dispatch.tunnel.secretKey = Dispatch.secretKey

Dispatch.tunnel.radioDev = Dispatch.radioDev
Dispatch.tunnel.playRadioMessage = Dispatch.playRadioMessage

vRP:registerExtension(Dispatch)