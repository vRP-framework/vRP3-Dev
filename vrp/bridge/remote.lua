local Tunnel = {}
Tunnel.__interfaces = {}
Tunnel.__pending = {}
Tunnel.__lastID = 0

local isServer = IsDuplicityVersion()

local function nextID()
  Tunnel.__lastID = Tunnel.__lastID + 1
  return tostring(Tunnel.__lastID)
end

function Tunnel.bind(name, iface)
  Tunnel.__interfaces[name] = iface

  RegisterNetEvent(name .. ":tunnel_req")
  AddEventHandler(name .. ":tunnel_req", function(method, args, rid)
    local src = source
    local interface = Tunnel.__interfaces[name]

    if not interface then
      print("[Tunnel] ❌ Interface not found for:", name)
      return
    end

    if not interface[method] then
      print("[Tunnel] ❌ Method", method, "not found on interface", name)
      return
    end

    local rets = table.pack(interface[method](src, table.unpack(args, 1, args.n)))

    if rid and rid ~= "" then
      if isServer then
        TriggerClientEvent(name .. ":tunnel_res", src, rid, rets)
      else
        TriggerServerEvent(name .. ":tunnel_res", rid, rets)
      end
    end
  end)
end

function Tunnel.get(name)
  RegisterNetEvent(name .. ":tunnel_res")
  AddEventHandler(name .. ":tunnel_res", function(rid, rets)
    local cb = Tunnel.__pending[rid]
    if cb then
      Tunnel.__pending[rid] = nil
      cb:resolve(table.unpack(rets, 1, rets.n))
    end
  end)

  local t = {}
  setmetatable(t, {
    __index = function(_, method)
      local isFire = method:sub(1, 1) == "_"
      local cleanMethod = isFire and method:sub(2) or method

      return function(target, ...)
        local args = table.pack(...)
        local rid = isFire and "" or nextID()

        if isFire then
          if isServer then
            if not target then
              error("[Tunnel] 🔥 Fire-and-forget: target is required for client call to '" .. cleanMethod .. "'")
            end
            TriggerClientEvent(name .. ":tunnel_req", target, cleanMethod, args, "")
          else
            TriggerServerEvent(name .. ":tunnel_req", cleanMethod, args, "")
          end
          return
        end

        local p = promise.new()
        Tunnel.__pending[rid] = p

        if isServer then
          TriggerClientEvent(name .. ":tunnel_req", target, cleanMethod, args, rid)
        else
          TriggerServerEvent(name .. ":tunnel_req", cleanMethod, args, rid)
        end

        return Citizen.Await(p)
      end
    end
  })

  return t
end

return Tunnel
