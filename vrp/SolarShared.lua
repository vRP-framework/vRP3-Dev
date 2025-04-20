local Tunnel = module('bridge/remote')
---@class SolarShared
local SolarShared = class("SolarShared")

---@class SolarShared.Modules
SolarShared.Modules = class("SolarShared.Modules")

function SolarShared.Modules:log(msg)
	SolarShared:log(msg)
end

function SolarShared.Modules:error(msg)
	SolarShared:error(msg)
end

function SolarShared.Modules:__construct()
	self.remote = setmetatable({}, {
		__index = function(_, className)
			return Tunnel.get('Solar.Mods.'..className)
		end
	})
end

function SolarShared:__construct()
	self.modules = {}
	
	self.queries={}
end
SolarShared.pendingCallbacks = {}
SolarShared.callbacks = {
	client = {},
	server = {}
}
SolarShared.ext_listeners = {}

function SolarShared:registerModule(classFn)
	local instance = classFn:new(self)
	local classname = instance.__name
	
	if not self.modules[classname] then
		self.modules[classname] = instance
		if classFn.tunnel then
			Tunnel.bind("Solar.Mods."..classname, classFn.tunnel)
		end

		if classFn.event then 
			for name,cb in pairs(classFn.event or {}) do
				local exts = self.ext_listeners[name]
				if not exts then
					exts = {}
					self.ext_listeners[name] = exts
				end

				exts[instance] = cb
				self:log('Events created for '.. classname)
			end
		end
	end
	self:log("Module "..classname.." loaded")
end

function SolarShared:triggerEvent(name, ...)
	local exts = self.ext_listeners[name] or Solar.ext_listeners
	if exts then
		local params = table.pack(...)
		for ext,func in pairs(exts) do
			func(ext,table.unpack(params,1,params.n))
		end
	end
end

function SolarShared:log(msg)
	print("[Solar] " .. msg)
end

function SolarShared:error(msg)
	error("[Solar] " .. msg)
end


function SolarShared:query(name, query)
	if not name or not query then
		return error('unable to create query due to invalid data passed.')
	end

	if not self.queries[name] then
		self.queries[name] = {
			query = query,
		}
	end
end

function SolarShared:execute(name, data)
	if not name then
		return error('Missing query name.')
	end

	if not self.queries[name] then
		SolarShared:log("Query ["..name.."] not found!")
		return nil
	end

	local query = self.queries[name].query
	local result

	if data then
		result = exports['oxmysql']:executeSync(query, data)
	else
		result = exports['oxmysql']:executeSync(query)
	end
	return result
end

-- 📣 Generate a unique event ID
local function generateEventID()
  return "cb_" .. tostring(math.random(100000, 999999))
end

-- 🔧 Register a callback function
function SolarShared:RegisterCallback(eventName, cb)
  if IsDuplicityVersion() then
    self.callbacks.server[eventName] = cb
  else
    self.callbacks.client[eventName] = cb
  end
end

-- 🔁 Trigger a callback (Client <-> Server)
function SolarShared:TriggerCallback(eventName, callback, target, ...)
  local isServer = IsDuplicityVersion()
  local args = { ... }

  if isServer then
    local cb = self.callbacks.server[eventName]
    if cb then
      local result = target and cb(target, table.unpack(args)) or cb(source, table.unpack(args))
      if callback then callback(result) end
      return
    end
  else
    local cb = self.callbacks.client[eventName]
    if cb then
      local result = cb(table.unpack(args))
      if callback then callback(result) end
      return
    end
  end

  -- not local: send to other side
  local eventID = generateEventID()
  self.pendingCallbacks[eventID] = callback

  if isServer then
    if not target then
      print("[Solar] ERROR: Missing target player ID for callback: " .. eventName)
      return
    end
    TriggerClientEvent("framework:triggerClient", target, eventName, eventID, table.unpack(args))
  else
    TriggerServerEvent("framework:triggerServer", eventName, eventID, table.unpack(args))
  end
end

-- 🌐 Server-side handler: client → server
if IsDuplicityVersion() then
  RegisterNetEvent("framework:triggerServer", function(eventName, eventID, ...)
    local src = source
    local cb = Solar.callbacks.server[eventName]
    if cb then
      local result = cb(src, ...)
      TriggerClientEvent("framework:serverResponse", src, eventID, result)
    else
      print("[Solar] Missing server callback for: " .. eventName)
    end
  end)
-- 🌐 Client-side handlers: server → client and response back
else
  RegisterNetEvent("framework:triggerClient", function(eventName, eventID, ...)
    local cb = Solar.callbacks.client[eventName]
    if cb then
      local result = cb(...)
      TriggerServerEvent("framework:serverResponse", eventID, result)
    else
      print("[Solar] Missing client callback for: " .. eventName)
    end
  end)

  RegisterNetEvent("framework:serverResponse", function(eventID, result)
    if SolarShared.pendingCallbacks[eventID] then
      SolarShared.pendingCallbacks[eventID](result)
      SolarShared.pendingCallbacks[eventID] = nil
    end
  end)
end

return SolarShared