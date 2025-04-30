local Tunnel = module('core','bridge/remote')

function FrameworkShared()
	local self = {}
	--- private variables
	local queries = {}
	local pendingCallbacks = {}
	local callbacks = {
		client = {},
		server = {}
	}
	local event_listeners = {}

	--- public variables
	self.modules = {}

	-- Modules sub class
	self.Modules = function(target)
		local shared = self

		function target:log(msg)
			shared:log(msg)
		end

		function target:error(msg)
			shared:error(msg)
		end

		target.remote = setmetatable({}, {
			__index = function(_, className)
				return Tunnel.get('Framework.Mods.'..className)
			end
		})
	end

	function self:log(msg, level)
		print('[Framework] '..msg)
	end

	function self:error(msg)
		error('[Framework] '..msg)
	end

	function self:RegisterModule(classFn)
		if type(classFn) ~= 'function' then
			return self:error('RegisterModule expected a function and got '..type(classFn))
		end

		local instance = classFn(self)
		if type(instance) ~= 'table' then
			return self:error("RegisterModule constructor did not return a table")
		end

		local classname = instance.__name
		if not classname then
			return self:error('Module is missing a name!')
		end

		if not self.modules[classname] then
			self.modules[classname] = instance
			print(' + Module added: ', classname)

			-- vrp2 inspired tunnel system
			if instance.tunnel then
				Tunnel.bind('Framework.Mods.'..classname, instance.tunnel)
			end

			-- custom event system
			if instance.event then
				for name,cb in pairs(instance.event) do
					event_listeners[name] = event_listeners[name] or {}
					event_listeners[name][instance] = cb
				end
			end

			if instance.__construct then
				instance:__construct()
			end
		end
	end


	function self:triggerEvent(name, ...)
		local events = event_listeners[name]
		if events then
			local params = table.pack(...)
			for evt, func in pairs(events) do
				if type(func) ~= 'table' then
					func(evt, table.unpack(params, 1, params.n))
				end
			end
		end
	end


	function self:query(name, query)
		if not name or not query then
			return error('unable to create query due to invalid data passed.')
		end
		if not queries[name] then
			queries[name] = {
				query = query,
			}
		end
	end

	function self:execute(name, data)
		if not name then
			return error('Missing query name.')
		end
		if not queries[name] then
			Framework:log("Query ["..name.."] not found!")
			return nil
		end
		local query = queries[name].query
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
	function self:RegisterCallback(eventName, cb)
		if IsDuplicityVersion() then
			callbacks.server[eventName] = cb
		else
			callbacks.client[eventName] = cb
		end
	end

	-- 🔁 Trigger a callback (Client <-> Server)
	function self:TriggerCallback(eventName, callback, target, ...)
		local isServer = IsDuplicityVersion()
		local args = { ... }

		if isServer then
			local cb = callbacks.server[eventName]
			if cb then
				local result = target and cb(target, table.unpack(args)) or cb(source, table.unpack(args))
				if callback then callback(result) end
				return
			end
		else
			local cb = callbacks.client[eventName]
			if cb then
				local result = cb(table.unpack(args))
				if callback then callback(result) end
				return
			end
		end

		-- not local: send to other side
		local eventID = generateEventID()
		pendingCallbacks[eventID] = callback

		if isServer then
			if not target then
				print("[Framework] ERROR: Missing target player ID for callback: " .. eventName)
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
			local cb = callbacks.server[eventName]
			if cb then
				local result = cb(src, ...)
				TriggerClientEvent("framework:serverResponse", src, eventID, result)
			else
				print("[Framework] Missing server callback for: " .. eventName)
			end
		end)
	end

	-- 🌐 Client-side handlers: server → client and response back
	if not IsDuplicityVersion() then
		RegisterNetEvent("framework:triggerClient", function(eventName, eventID, ...)
			local cb = callbacks.client[eventName]
			if cb then
				local result = cb(...)
				TriggerServerEvent("framework:serverResponse", eventID, result)
			else
				print("[Framework] Missing client callback for: " .. eventName)
			end
		end)

		RegisterNetEvent("framework:serverResponse", function(eventID, result)
			if pendingCallbacks[eventID] then
				pendingCallbacks[eventID](result)
				pendingCallbacks[eventID] = nil
			end
		end)
	end

	return self
end

return FrameworkShared