-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

--[[
MIT License

Copyright (c) 2017 ImagicTheCat

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local vRPShared = class("vRPShared")

-- SUBCLASS

-- Extension class
-- define .proxy/.tunnel for proxy and tunnel interfaces
-- ex: 
-- MyExt.tunnel = {}
-- function MyExt.tunnel:add(a,b) return a+b end
-- MyExt.remote.add(1,1) => 2
--
-- .proxy will create the extension proxy with interface name "vRP.EXT.<name>"
--
-- .event properties are listener callbacks
-- ex:
-- function MyExt.event:playerJoin(...) ... end
--
-- .User: optional class inherited by User (to extend User behavior, constructor will be executed)
vRPShared.Extension = class("vRPShared.Extension")

function vRPShared.Extension:__construct()
  -- init extension tunnel and proxy
  if self.tunnel then -- build tunnel interface
    self.tunnel_interface = {}
    for k,v in pairs(self.tunnel) do
      self.tunnel_interface[k] = function(...)
        return v(self, ...)
      end
    end

    Tunnel.bindInterface("vRP.EXT."..class.name(self), self.tunnel_interface)
  end

  if self.proxy then -- build tunnel interface
    self.proxy_interface = {}
    for k,v in pairs(self.proxy) do
      self.proxy_interface[k] = function(...)
        return v(self, ...)
      end
    end

    Proxy.addInterface("vRP.EXT."..class.name(self), self.proxy_interface)
  end

  -- tunnel remote
  self.remote = Tunnel.getInterface("vRP.EXT."..class.name(self))
end

-- Metrics helpers removed

-- level: (optional) level, 0 by default
function vRPShared.Extension:log(msg, level)
  vRP:log(msg, class.name(self), level)
end

function vRPShared.Extension:error(msg)
  vRP:error(msg, class.name(self))
end

-- METHODS

function vRPShared:__construct()
  -- extensions
  self.EXT = {} -- map of name => ext
  self.ext_listeners = {} -- map of name => map of ext => callback
  self.ext_sources = {} -- map of name => {rsc=, path=} for the CURRENTLY registered instance; cleared by unregisterExtension
  self.known_sources = {} -- map of name => {rsc=, path=}; remembers a source across stop/start, never cleared (see startExtension)

  self.modules = module("vrp", "cfg/modules")

  self.log_level = 0

  -- triggered externally (TriggerEvent("vRP:reload") or TriggerEvent("vRP:reload", {"Weapon","GUI"}))
  -- to hot-reload extensions registered with a source; see reloadExtensions
  AddEventHandler("vRP:reload", function(only)
    self:reloadExtensions(only)
  end)
end

-- register an extension
-- extension: Extension class
-- source: (optional) {rsc=, path=} the resource/module() path this extension
--   class was loaded from, e.g. {rsc="vrp", path="modules/admin"}. Usually
--   not needed: when omitted, it's auto-derived from the chunkname of
--   whoever called registerExtension (see below), which is correct for the
--   normal "class defined at the top of a module() file, registered at the
--   bottom of that same file" pattern used throughout vrp/modules/*.lua.
--   Pass it explicitly only if registerExtension is called indirectly
--   (through a wrapper function) where auto-detection would point at the
--   wrapper instead of the actual module file.
--   Either way this is only needed to make the extension reloadable via
--   reloadExtensions(); extensions without a resolvable source keep working
--   normally, they just can't be hot-reloaded (reloadExtensions skips them).
function vRPShared:registerExtension(extension, source)
	--self:log("register EXT: " .. tostring(extension))
  if class.is(extension, vRPShared.Extension) then
    if not self.EXT[class.name(extension)] then
      -- auto-derive source from the caller's chunkname if not given.
      -- module() loads files via load(code, rsc.."/"..path..".lua"); FXServer's
      -- Lua runtime prepends its own "@" chunk-file marker(s) on top of that
      -- (verified live: e.g. "@@vrp/modules/admin.lua"), so strip any leading
      -- "@" before matching. Restricted to "modules/*" on purpose: also
      -- verified live that native server_script entry files (this resource's
      -- own base.lua, or another resource's server.lua) can produce chunknames
      -- matching the same rsc/path.lua shape -- those are NOT safe to reload
      -- (re-load()-ing them re-runs top-level RegisterCommand/RegisterNetEvent
      -- side effects a second time), so only the modules/ convention actually
      -- used for reloadable extension files is accepted here.
      if not source then
        local info = debug.getinfo(2, "S")
        if info and info.source then
          local clean = info.source:gsub("^@+", "")
          local rsc, path = clean:match("^([%w_%-]+)/(modules/[%w_%-]+)%.lua$")
          if rsc and path then source = {rsc = rsc, path = path} end
        end
      end

      -- instantiate
      local ext = extension()
      self.EXT[class.name(extension)] = ext
      self.ext_sources[class.name(extension)] = source
      if source then self.known_sources[class.name(extension)] = source end

      -- bind listeners
      if extension.event then
        local ext_name = class.name(extension)
        for name,cb in pairs(extension.event or {}) do
          local exts = self.ext_listeners[name]
          if not exts then -- create
            exts = {}
            self.ext_listeners[name] = exts
          end

          exts[ext] = cb
        end
      end

      
      self:log("Extension "..class.name(ext).." loaded.")

      self:triggerEvent("extensionLoad", ext)
    else
      self:error("An extension named "..class.name(extension).." is already registered.")
    end
  else
    self:error("Not an Extension class.")
  end
end

-- Unregister an extension
-- Tears down everything registerExtension/Extension:__construct set up for
-- this instance (listeners, tunnel/proxy bindings, remote interface) so the
-- old instance is fully unreachable afterwards -- required for reloading an
-- extension without leaking the previous instance's bindings.
function vRPShared:unregisterExtension(extension_name)
  local ext = self.EXT[extension_name]
  if ext then
    -- Unbind listeners
    for name, exts in pairs(self.ext_listeners) do
      exts[ext] = nil
      if not next(exts) then
        self.ext_listeners[name] = nil
      end
    end

    -- Unbind tunnel/proxy interfaces this extension exposed to callers
    if ext.tunnel then
      Tunnel.unbindInterface("vRP.EXT."..extension_name)
    end
    if ext.proxy then
      Proxy.removeInterface("vRP.EXT."..extension_name)
    end
    -- Stop listening for responses to calls this extension made via self.remote
    Tunnel.releaseInterface("vRP.EXT."..extension_name)

    -- Remove any menu builders this extension registered on GUI -- those
    -- are closures over this instance; left alone they'd keep running a
    -- "stopped" extension, or duplicate on the next start/reload (confirmed
    -- live with Weapon's weapon-type menu).
    if self.EXT.GUI and self.EXT.GUI.unregisterMenuBuilders then
      self.EXT.GUI:unregisterMenuBuilders(extension_name)
    end

    -- Trigger unload event (optional, if extensions handle their cleanup)
    if ext.event and ext.event.unload then
      ext.event.unload(ext)
    end
    -- Remove the extension
    self.EXT[extension_name] = nil
    self.ext_sources[extension_name] = nil
    self:log("Extension " .. extension_name .. " unloaded.")
  else
    self:error("Extension " .. extension_name .. " not found for unloading.")
  end
end

-- Stop a currently-running extension and leave it stopped (unlike
-- reloadExtensions, this does not bring it back). Case-insensitive,
-- non-throwing "not running" handling (logs instead), meant to be safe to
-- call directly from an admin command. Its module source (if any) stays
-- remembered in known_sources so startExtension can bring it back later.
function vRPShared:stopExtension(name)
  local actual
  for ext_name in pairs(self.EXT) do
    if string.lower(ext_name) == string.lower(name) then
      actual = ext_name
      break
    end
  end
  if not actual then
    self:log("Cannot stop " .. tostring(name) .. ": not currently running.")
    return false
  end
  self:unregisterExtension(actual)
  return true
end

-- (Re)start a previously-registered extension that is not currently
-- running, using its remembered module source (see registerExtension/
-- known_sources). No-op if already running; logs (does not throw) if it has
-- no known source -- i.e. it was never registered with one, so there's
-- nothing to reload it from.
function vRPShared:startExtension(name)
  local actual, source
  for known_name, known_source in pairs(self.known_sources) do
    if string.lower(known_name) == string.lower(name) then
      actual, source = known_name, known_source
      break
    end
  end
  if not actual then
    self:log("Cannot start " .. tostring(name) .. ": no known module source (never registered with one).")
    return false
  end
  if self.EXT[actual] then
    self:log(actual .. " is already running.")
    return false
  end

  unloadModule(source.rsc, source.path) -- force a fresh read from disk
  -- re-running the file re-registers the extension as a side effect, see
  -- reloadExtensions for why this doesn't use module()'s return value
  local ok, err = pcall(module, source.rsc, source.path)
  if not ok then
    self:log("Failed to start " .. actual .. ": " .. tostring(err))
    return false
  end
  return true
end

-- Hot-reload extensions that have a recorded source (see registerExtension's
-- source parameter). Extensions without one are left running untouched --
-- there is no case for those. Note: any code holding a stale reference to
-- the pre-reload instance (e.g. a variable that captured vRP.EXT.Foo once
-- instead of looking it up fresh each time) will keep pointing at the old,
-- now-unregistered instance; this is a caller responsibility, not something
-- reloadExtensions can fix for you.
-- only: (optional) list of extension names to reload (case-insensitive,
--   matched against currently registered extensions); if omitted or empty,
--   reloads every currently registered extension that has a source.
function vRPShared:reloadExtensions(only)
  local names = {}
  if only and #only > 0 then
    local by_lower = {}
    for extension_name in pairs(self.EXT) do
      by_lower[string.lower(extension_name)] = extension_name
    end
    for _, requested in ipairs(only) do
      local actual = by_lower[string.lower(requested)]
      if actual then
        table.insert(names, actual)
      else
        self:log("Skipped reload for "..tostring(requested)..": not a registered extension.")
      end
    end
  else
    for extension_name in pairs(self.EXT) do
      table.insert(names, extension_name)
    end
  end

  -- GUI is a hub other extensions register menu builders against from their
  -- own __construct (vRP.EXT.GUI:registerMenuBuilder(...)). If GUI reloads
  -- AFTER something that depends on it, that extension's registrations land
  -- on the about-to-be-discarded old GUI instance and are silently lost
  -- (confirmed live: Identity's menu builders vanished this way). Reload it
  -- first so everything else in this pass targets the final GUI instance.
  table.sort(names, function(a, b)
    if a == "GUI" then return true end
    if b == "GUI" then return false end
    return false
  end)

  for _, extension_name in ipairs(names) do
    local source = self.ext_sources[extension_name]
    if not source then
      self:log("Skipped reload for "..extension_name..": registered without a source, not reloadable.")
    else
      self:unregisterExtension(extension_name)
      unloadModule(source.rsc, source.path) -- evict cached code, force re-read from disk

      -- Re-running the file re-registers the extension as a side effect --
      -- every vrp/modules/*.lua file ends with its own top-level
      -- registerExtension call, it does not return the class for us to
      -- register ourselves (these files were written to be loaded once as
      -- server_script entries, not as return-a-value module() imports).
      -- Wrapped in pcall so one module failing to reload (syntax error,
      -- missing file) doesn't abort reloading the rest -- self:error()
      -- throws, and this loop must keep going after a single failure.
      local ok, err = pcall(module, source.rsc, source.path)
      if not ok then
        self:log("Failed to reload "..extension_name..": "..tostring(err))
      end
    end
  end

  self:log("Extension reload pass complete.")
end

-- trigger event (with async call for each listener)
function vRPShared:triggerEvent(name, ...)
  local exts = self.ext_listeners[name]
  if exts then
    local params = table.pack(...)
    for ext,func in pairs(exts) do
      async(function()
        func(ext, table.unpack(params, 1, params.n))
      end)
    end
  end
end

-- trigger event and wait for all listeners to complete
function vRPShared:triggerEventSync(name, ...)
  local exts = self.ext_listeners[name]
  if exts then
    local params = table.pack(...)
    local count = 0
    local r = async()
    for ext, func in pairs(exts) do
      count = count+1
    end
    for ext,func in pairs(exts) do
      async(function()
        func(ext, table.unpack(params, 1, params.n))
        count = count-1
        if count == 0 then -- all done
          r()
        end
      end)
    end
    r:wait() -- wait events completion
  end
end

-- msg: log message
-- suffix: (optional) category, string
-- level: (optional) level, 0 by default
function vRPShared:log(msg, suffix, level)
  if not level then level = 0 end

  if level <= self.log_level then
    if suffix then
      print("[vRP:"..suffix.."] "..msg)
    else
      print("[vRP] "..msg)
    end
  end
end

-- msg: error message
-- suffix: optional category, string
function vRPShared:error(msg, suffix)
  if suffix then
    error("[vRP:"..suffix.."] "..msg)
  else
    error("[vRP] "..msg)
  end
end

return vRPShared;