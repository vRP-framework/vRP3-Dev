-- Bootstraps this resource's own client vRP instance: sets the Tunnel,
-- Proxy, and vRP globals via vrp/client/bootstrap.lua. Safe to call from
-- more than one client-side file in this resource -- module() caches by
-- path, so only the first call actually runs the bootstrap; later calls
-- just return the same instance instead of creating a second one.
vRP = module("vrp", "client/bootstrap")

local cfg = module("vrp_template", "cfg/cfg")

local Template = class("Template", vRP.Extension)

function Template:__construct()
  vRP.Extension.__construct(self)

  -- client-side init goes here: RegisterNUICallback, RegisterCommand,
  -- RegisterKeyMapping, local state, etc.
end

-- EVENT: vRP lifecycle hooks fire here, e.g. (client-side events take no
-- arguments -- there's only ever "the local player" on this side):
-- Template.event = {}
-- function Template.event:playerSpawn() end

-- TUNNEL: remote calls made from the server (self.remote.xxx(...) there)
-- land here, e.g.:
-- function Template:someRemoteAction(...) end
-- Template.tunnel = {}
-- Template.tunnel.someRemoteAction = Template.someRemoteAction

vRP:registerExtension(Template)
