Core.ServerCallbacks, Core.CurrentRequestId = {}, 0
 
Core.TriggerServerCallback = function(name, cb, ...)
	Core.ServerCallbacks[Core.CurrentRequestId] = cb

	TriggerServerEvent('dh_lib:server:triggerServerCallback', name, Core.CurrentRequestId, ...)

	if Core.CurrentRequestId < 65535 then
		Core.CurrentRequestId = Core.CurrentRequestId + 1
	else
		Core.CurrentRequestId = 0
	end
end

RegisterNetEvent('dh_lib:client:serverCallback', function(requestId, ...)
	if not Core.ServerCallbacks[requestId] then return end
	Core.ServerCallbacks[requestId](...)
	Core.ServerCallbacks[requestId] = nil
end)

LoadedSystems['callbacks'] = true