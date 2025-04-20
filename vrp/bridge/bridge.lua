local Proxy = {}
local rscname = GetCurrentResourceName()

local function proxy_resolve(itable, key)
  local meta = getmetatable(itable)
  local name = meta.name
  local callbacks = meta.callbacks
  local identifier = meta.identifier
  local no_wait = key:sub(1,1) == "_"
  local fname = no_wait and key:sub(2) or key

  local function fcall(...)
    local rid = no_wait and -1 or math.random(1, 1000000)
    local r
    if rid > 0 then
      r = async()
      callbacks[rid] = r
    end
    TriggerEvent(name..":proxy", fname, table.pack(...), identifier, rid)
    if rid > 0 then return r:wait() end
  end

  itable[key] = fcall
  return fcall
end

function Proxy.addInterface(name, methods)
  AddEventHandler(name..":proxy", function(fname, args, identifier, rid)
    local fn = methods[fname]
    if fn then
      local rets = table.pack(fn(table.unpack(args, 1, args.n)))
      if rid >= 0 then
        TriggerEvent(name..":"..identifier..":proxy_res", rid, rets)
      end
    else
      print("Proxy error: "..name.."."..fname.." not found")
    end
  end)
end

function Proxy.getInterface(name, identifier)
  identifier = identifier or rscname
  local callbacks = {}
  local proxy = setmetatable({}, {
    __index = proxy_resolve,
    name = name,
    callbacks = callbacks,
    identifier = identifier
  })

  AddEventHandler(name..":"..identifier..":proxy_res", function(rid, rets)
    local cb = callbacks[rid]
    if cb then
      callbacks[rid] = nil
      cb(table.unpack(rets, 1, rets.n))
    end
  end)

  return proxy
end

return Proxy
