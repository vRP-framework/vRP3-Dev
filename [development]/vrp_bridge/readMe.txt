VRP_BRIDGE - CREATING NEW EXPORTS (FULL 3-LAYER EXAMPLE)
========================================================

Goal: Create a new export for adding cash to a player.

----------------------------------------------------------------------
1. EXPORT.LUA
----------------------------------------------------------------------

-- Expose a safe export function for other resources
exports('addCash', secureExport(function(source, amount)
    source, amount = tonumber(source), tonumber(amount)
    if amount <= 0 then return false end
    return Bridge.addCash(source, amount) -- call the bridge layer
end))

----------------------------------------------------------------------
2. INIT.LUA (Bridge Layer)
----------------------------------------------------------------------

-- Bridge functions link exports to VRP core
Bridge = {}

function Bridge.addCash(source, amount)
	-- Call the VRP proxy function
	return vRP.addCash(source, amount)
end

----------------------------------------------------------------------
3. SERVER.LUA (VRP Core / Proxy)
----------------------------------------------------------------------

-- Define your VRP extension
-- ensure any new  proxy functions are inside the registerExtension function
local function registerExtension(extensionName)
	local extension = class(extensionName, vRP.Extension)

	extension.event = {}
	extension.tunnel = {}
	extension.proxy = {}

	function extension:__construct()
		vRP.Extension.__construct(self)
	end

	-- Core proxy function
	function extension.proxy:addCash(source, amount)
		local user = vRP.users_by_source[source]
		if not user then return false end
		return user:giveWallet(amount)
	end
end

----------------------------------------------------------------------
USAGE EXAMPLE FROM ANOTHER RESOURCE
----------------------------------------------------------------------
-- ensure source is passed in
local amount = 500

-- Call the export safely
local success = exports['vrp_bridge']:addCash(source, amount)
if success then
	print("Cash added successfully")
else
	print("Failed to add cash")
end

======================================
VRP_BRIDGE - EXPORT REFERENCE & CONFIG
======================================

Use these exports to interact with the VRP framework via vrp_bridge.

----------------------------------------------------------------------
EXPORTS
----------------------------------------------------------------------

NOTIFICATIONS
-------------
notify(source, message)
- Sends a notification to a player.
- source: player ID
- message: string
- Example:
  exports['vrp_bridge']:notify(source, "You received money!")

CHARACTER
---------
getCharacterName(source)
- Returns: firstName, lastName
- Example:
  local first, last = exports['vrp_bridge']:getCharacterName(source)

INVENTORY
---------
getItemAmount(source, itemName)
- Returns number of items a player has.
- Example:
  local amt = exports['vrp_bridge']:getItemAmount(source, "water")

addItem(source, itemName, amount)
- Adds items to a player.
- Example:
  exports['vrp_bridge']:addItem(source, "water", 5)

removeItem(source, itemName, amount)
- Removes items from a player.
- Example:
  exports['vrp_bridge']:removeItem(source, "water", 2)

registerItem(item, name, description)
- Registers a new item.
- Example:
  exports['vrp_bridge']:registerItem("water", "Bottle of Water", "Restores hydration")

CASH (WALLET)
-------------
getWallet(source)
- Returns player’s cash balance.
- Example:
  local cash = exports['vrp_bridge']:getWallet(source)

addCash(source, amount)
- Adds cash to a player.
- Example:
  exports['vrp_bridge']:addCash(source, 500)

removeCash(source, amount)
- Removes cash from a player.
- Example:
  exports['vrp_bridge']:removeCash(source, 200)

BANK
----
getBank(source)
- Returns player’s bank balance.
- Example:
  local bank = exports['vrp_bridge']:getBank(source)

addBank(source, amount)
- Adds money to a player’s bank.
- Example:
  exports['vrp_bridge']:addBank(source, 1000)

removeBank(source, amount)
- Removes money from a player’s bank.
- Example:
  exports['vrp_bridge']:removeBank(source, 500)

JOB
---
getJob(source)
- Returns player’s job name.
- Example:
  local job = exports['vrp_bridge']:getJob(source)
  if job == "police" then
		exports['vrp_bridge']:notify(source, "You are police!")
  end

----------------------------------------------------------------------
CONFIGURATION
----------------------------------------------------------------------

Allowed Resources
-----------------
Resources that can use vrp_bridge exports are controlled in the config:

Config.AllowedResources = {
	["devhub_lib"] = true,
	["vrp_jobs"] = true,
	["vrp_admin"] = true
}

- Only listed resources are allowed access.
- Resource names must match exactly.

Allow VRP Prefix
----------------
Config.AllowVRPResources = true
- When true, any resource whose name starts with "vrp_" is automatically allowed.
- Example: "vrp_police" or "vrp_garage"

Debugging
---------
Config.DebugSecurity = true
- Prints unauthorized export attempts to the server console.

Usage Example
-------------
-- Give $500 to a police officer
local job = exports['vrp_bridge']:getJob(source)
if job == "police" then
	exports['vrp_bridge']:addCash(source, 500)
end

-- Remove item from player if available
local amount = exports['vrp_bridge']:getItemAmount(source, "lockpick")
if amount > 0 then
	exports['vrp_bridge']:removeItem(source, "lockpick", 1)
end