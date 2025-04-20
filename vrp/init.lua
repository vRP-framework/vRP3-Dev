function class(name, base, def)
  local cls = {}
  cls.__name = name
  cls.__base = base

  -- Inherit from base
  if base then
    for k, v in pairs(base) do
      if cls[k] == nil then
        cls[k] = v
      end
    end
  end

  -- Apply definition
  if def then def(cls) end

  -- Constructor
  function cls:new(...)
    local obj = {}
    for k, v in pairs(cls) do
      obj[k] = v
    end

    obj.__name = name
    obj.__base = base

    if obj.__construct then obj:__construct(...) end
    return obj
  end

  return cls
end


SERVER = IsDuplicityVersion()
CLIENT = not SERVER

local modules = {}

function module(resource, path)
  if not path then
    path = resource
    resource = GetCurrentResourceName()
  end

  local key = resource .. '/' .. path
  local cached = modules[key]

  if cached then
    return table.unpack(cached.rets or {}, 1, cached.n or 0)
  else
    local code = LoadResourceFile(resource, path .. '.lua')
    if not code then
      error('resource file ' .. resource .. '/' .. path .. '.lua not found.')
    end

    local f, err = load(code, resource .. '/' .. path .. '.lua')
    if not f then
      error('error parsing module ' .. resource .. '/' .. path .. ':' .. err)
    end

    local success, result = xpcall(f, debug.traceback)
    if not success then
      error('error loading module ' .. resource .. '/' .. path .. ':' .. result)
    end

    local rets = { result }
    modules[key] = { rets = rets, n = #rets }

    return table.unpack(rets)
  end
end

local function wait(self)
  local r = Citizen.Await(self.p)
  if not r then
    if self.r then
      r = self.r
    else
      error("async wait(): Citizen.Await returned (nil) before the areturn call.")
    end
  end
  return table.unpack(r, 1, r.n)
end

local function areturn(self, ...)
  self.r = table.pack(...)
  self.p:resolve(self.r)
end

-- create an async returner or a thread (Citizen.CreateThreadNow)
-- func: if passed, will create a thread, otherwise will return an async returner
function async(func)
  if func then
    Citizen.CreateThreadNow(func)
  else
    return setmetatable({ wait = wait, p = promise.new() }, { __call = areturn })
  end
end