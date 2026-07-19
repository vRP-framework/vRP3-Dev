-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

-- Proxy interface system, used to add/call functions between resources

local IDManager = module("lib/IDManager")

local Proxy = {}
local rscname = GetCurrentResourceName()

-- max time (ms) to wait for a proxy response before freeing the request
-- (covers the target resource stopping/erroring before it can respond)
Proxy.request_timeout = 30000

-- free a pending request if it never got a response (timeout)
local function schedule_timeout(ids, callbacks, rid)
  SetTimeout(Proxy.request_timeout, function()
    local callback = callbacks[rid]
    if callback then -- still pending, no response ever arrived
      callbacks[rid] = nil
      ids:free(rid)
      callback() -- resolve with no values (same as an unbound member response)
    end
  end)
end

local function proxy_resolve(itable,key)
  local mtable = getmetatable(itable)
  local iname = mtable.name
  local ids = mtable.ids
  local callbacks = mtable.callbacks
  local identifier = mtable.identifier
  local fname = key
  local no_wait = false
  if string.sub(key,1,1) == "_" then
    fname = string.sub(key,2)
    no_wait = true
  end
  -- generate access function
  local fcall = function(...)
    local rid, r
    local profile -- debug
    if no_wait then
      rid = -1
    else
      r = async()
      rid = ids:gen()
      callbacks[rid] = r
      schedule_timeout(ids, callbacks, rid)
    end
    TriggerEvent(iname..":proxy", fname, table.pack(...), identifier, rid)
    if not no_wait then return r:wait() end
  end
  itable[key] = fcall -- add generated call to table (optimization)
  return fcall
end

-- add event handler to call interface functions
-- name: interface name
-- itable: table containing functions
function Proxy.addInterface(name, itable)
  AddEventHandler(name..":proxy", function(member, args, identifier, rid)
    local f = itable[member]
    local rets
    if type(f) == "function" then
      local ok, err = xpcall(function()
        rets = table.pack(f(table.unpack(args, 1, args.n)))
      end, debug.traceback)
      if not ok then
        print("^1[Proxy] error in "..name.."."..tostring(member)..": "..tostring(err).."^7")
        rets = nil
      end
      -- CancelEvent() -- cancel event doesn't seem to cancel the event for the other handlers, but if it does, uncomment this
    else
      print("error: proxy call "..name..":"..member.." not found")
    end
    if rid >= 0 then
      TriggerEvent(name..":"..identifier..":proxy_res", rid, rets or table.pack())
    end
  end)
end

-- get a proxy interface 
-- name: interface name
-- identifier: (optional) unique string to identify this proxy interface access; if nil, will be the name of the resource
function Proxy.getInterface(name, identifier)
  if not identifier then identifier = GetCurrentResourceName() end
  local ids = IDManager()
  local callbacks = {}
  local r = setmetatable({},{ __index = proxy_resolve, name = name, ids = ids, callbacks = callbacks, identifier = identifier })
  AddEventHandler(name..":"..identifier..":proxy_res", function(rid, rets)
    local callback = callbacks[rid]
    if callback then
      -- free request id
      ids:free(rid)
      callbacks[rid] = nil
      -- call
      callback(table.unpack(rets, 1, rets.n))
    end
  end)
  return r
end

return Proxy
