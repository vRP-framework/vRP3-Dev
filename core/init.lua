function class(def, base)
  local self = {}
  setmetatable(self, { __index = base })
  def(self)
  return self
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
	if not (r and self.r) then
		r = self.r 
	elseif not r then
		error('Wait() failed: await resolved with nil and no areturn fallback value')
	end
	return table.unpack(r, 1, r.n)
end

local function areturn(self, ...)
	if not self._resolved then
		self.r = table.pack(...)
		self._resolved = true 
		self.p:resolve(self.r)
	end
end

function async(func)
	if func then
		Citizen.CreateThreadNow(func)
	else
		return setmetatable({
			wait = wait,
			p = promise.new(),
			r = nil,
			_resolved = false
		}, { __call = areturn })
	end
end

function splitString(str, sep)
  if sep == nil then sep = "%s" end
  local t={}
  local i=1
  for str in string.gmatch(str, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end