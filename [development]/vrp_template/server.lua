-- IMPORTANT: this file is never declared as a server_script in
-- fxmanifest.lua. @vrp/lib/init.lua (the only server_script this resource
-- has) runs inside this resource, requires Tunnel/Proxy, gets the "vRP"
-- proxy interface, and calls vRP.loadScript(GetCurrentResourceName(),
-- "server") -- which tells vRP *core* (the [vrp]/vrp resource) to load and
-- execute this file INSIDE vRP core's own already-bootstrapped Lua
-- environment, not inside this resource's own environment. That's why vRP,
-- class, module, msgpack, clone, etc. are already available as globals
-- below with no explicit require -- they're the exact same globals vRP
-- core's own modules (business.lua, inventory.lua, etc.) use, because this
-- code is literally running alongside them.
--
-- Practical effect: vRP.EXT.X is available immediately (no waiting for a
-- ready event), and a /vrpReload <ThisExtensionName> can reload just this
-- file without restarting the whole resource -- same as any core module.

local Template = class("Template", vRP.Extension)
Template.event = {}
Template.tunnel = {}

function Template:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp_template", "cfg/cfg")

  -- server-side init goes here: RegisterCommand, GUI menu builders
  -- (vRP.EXT.GUI:registerMenuBuilder), periodic threads, etc.
end

-- EVENT: vRP lifecycle hooks, e.g.:
-- function Template.event:playerSpawn(user, first_spawn) end

-- called by vRPShared:unregisterExtension on /vrpReload or /vrpStop --
-- stop any threads you started in __construct here so a reload doesn't
-- leave a duplicate running against a dead instance
-- function Template.event:unload() end

-- TUNNEL: remote calls made from the client (self.remote.xxx(...) there)
-- land here, e.g.:
-- function Template:someAction(...) end
-- Template.tunnel.someAction = Template.someAction

vRP:registerExtension(Template)
