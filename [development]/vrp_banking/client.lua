--##########	VRP Main	##########--
-- init vRP server context
Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

local cvRP = module("vrp", "client/vRP")
vRP = cvRP()

local pvRP = {}
-- load script in vRP context
pvRP.loadScript = module
Proxy.addInterface("vRP", pvRP)

local cfg = module("vrp_banking", "cfg/cfg")
local Banking = class("Banking", vRP.Extension)
local display = false

function Banking:__construct()
	vRP.Extension.__construct(self)

  self.models = {
    atm = {
      GetHashKey("prop_atm_01"),
      GetHashKey("prop_atm_02"),
      GetHashKey("prop_atm_03"),
      GetHashKey("prop_fleeca_atm")
    }
  }

  RegisterNUICallback("processTransaction", function(data, cb)
    local success = self.remote.action(data)

    cb({ ok = success == true })
  end)

  RegisterNUICallback("closeUI", function(data, cb)
    self:closeUI()
    cb('ok')
  end)

  RegisterNUICallback("closeBankUI", function(data, cb)
    self:closeUI()
    cb('ok')
  end)
end

function Banking:userData(userData)
  SendNUIMessage({
		action = "updateUser",
		data = userData
	})
end

function Banking:updateContacts(contacts)
  SendNUIMessage({
		action = "updateContacts",
		data = contacts
	})
end

function Banking:closeUI()
  SetNuiFocus(false, false)
  SetDisplay(false)

  ClearTimecycleModifier()
end

function SetDisplay(bool)
  display = bool
  SetNuiFocus(bool, bool)
  SendNUIMessage({
    action = "setVisible", 
    data = bool
  })
end

function Banking:openUI(path)
  SetNuiFocus(true, true)
  SendNUIMessage({
    action = "setVisible",
    data = {
      visible = true,
      path = path
    }
  })

  SetTimecycleModifier("hud_def_blur")
  SetTimecycleModifierStrength(1.0)
end

--**********************************
-- Debug Functions
--**********************************

function Banking:debug(path)
  self:openUI(path)
end

function Banking:GetATMs()
  print("Getting ATM locations...")
  local atms = {}

  local handle, object = FindFirstObject()
  local success

  print("ATM Models:", json.encode(self.models.atm))

  repeat
    local model = GetEntityModel(object)
    print("Found Object Model:", model)

    for _, atmModel in ipairs(self.models.atm) do
      print("Checking against ATM Model:", atmModel)
      if model == atmModel then
        local coords = GetEntityCoords(object)

        print("Found ATM at:", json.encode(coords))
        table.insert(atms, {
          x = coords.x,
          y = coords.y,
          z = coords.z
        })
        break
      end
    end

    success, object = FindNextObject(handle)
  until not success

  EndFindObject(handle)

  print(json.encode(atms))
  return atms
end

Banking.tunnel = {}

-- UI
Banking.tunnel.userData 				      = Banking.userData
Banking.tunnel.updateContacts 				= Banking.updateContacts
Banking.tunnel.openUI					        = Banking.openUI
Banking.tunnel.closeUI 				        = Banking.closeUI

--Function
Banking.tunnel.debug 					        = Banking.debug
Banking.tunnel.GetATMs					      = Banking.GetATMs

vRP:registerExtension(Banking)
