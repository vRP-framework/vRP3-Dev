-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

-- Bootstraps this resource's own client vRP instance: sets the Tunnel,
-- Proxy, and vRP globals, and registers the "vRP" proxy interface used for
-- remote module loading. Every client-side vRP resource needs this once.
--
-- usage, from your resource's main client entry file:
--   vRP = module("vrp", "client/bootstrap") -- returns the instance directly, no trailing ()
--
-- Safe to call from more than one file: module() caches by path, so only
-- the first call actually runs this and sets the globals -- later calls
-- just return the same already-bootstrapped vRP instead of creating a
-- second, separate instance.

Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

local cvRP = module("vrp", "client/vRP")
vRP = cvRP()

local pvRP = {}
function pvRP.loadScript(resource, path)
  module(resource, path)
end
Proxy.addInterface("vRP", pvRP)

return vRP
