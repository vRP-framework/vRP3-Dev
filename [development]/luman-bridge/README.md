# Luman Bridge

A bridge for FiveM frameworks such ESX, QBCore, Qbox and vRP.


## Usage

### Shared Functions

```lua
-- shared.lua
local bridge = exports['luman-bridge']

-- Get the current framework name
local frameworkName = bridge:getFrameworkName()
```

### Server Functions

```lua
-- server.lua
local bridge = exports['luman-bridge']

-- Notifications
bridge:notify(playerId, message)

-- Character Information
local firstName, lastName = bridge:getCharacterName(playerId)

-- Inventory Management
local itemAmount = bridge:getItemAmount(playerId, 'bandage')
local success = bridge:addItem(playerId, 'bandage', 5)
local success = bridge:removeItem(playerId, 'lockpick', 1)

-- Money Management
local currentMoney = bridge:getMoneyAmount(playerId)
local success = bridge:addMoney(playerId, 1000)
local success = bridge:removeMoney(playerId, 500)

-- Job
local currentJob = bridge:getJob(playerId)
```

### Client Functions

```lua
-- client.lua
local bridge = exports['luman-bridge']

-- Notifications (client-side)
bridge:notify('Hello World!')
```

## API Reference

### Notifications

#### `notify(playerId, message)` (Server)
Shows a notification to the specified player.
- **playerId**: `number` - The player's server ID
- **message**: `string` - The notification message

#### `notify(message)` (Client)
Shows a notification to the local player.
- **message**: `string` - The notification message

### Character

#### `getCharacterName(playerId)`
Gets the character name of the specified player.
- **playerId**: `number` - The player's server ID
- **Returns**: `string, string` - firstName, lastName

### Inventory

#### `getItemAmount(playerId, itemName)`
Gets the amount of a specific item the player has.
- **playerId**: `number` - The player's server ID
- **itemName**: `string` - The item name
- **Returns**: `number` - Amount of the item

#### `addItem(playerId, itemName, amount)`
Adds items to the player's inventory.
- **playerId**: `number` - The player's server ID
- **itemName**: `string` - The item name
- **amount**: `number` - Amount to add (defaults to 1)
- **Returns**: `boolean` - Success status

#### `removeItem(playerId, itemName, amount)`
Removes items from the player's inventory.
- **playerId**: `number` - The player's server ID
- **itemName**: `string` - The item name
- **amount**: `number` - Amount to remove (defaults to 1)
- **Returns**: `boolean` - Success status

### Money

#### `getMoneyAmount(playerId)`
Gets the player's current money amount.
- **playerId**: `number` - The player's server ID
- **Returns**: `number` - Current money amount

#### `addMoney(playerId, amount)`
Adds money to the player.
- **playerId**: `number` - The player's server ID
- **amount**: `number` - Amount to add (must be positive)
- **Returns**: `boolean` - Success status

#### `removeMoney(playerId, amount)`
Removes money from the player.
- **playerId**: `number` - The player's server ID
- **amount**: `number` - Amount to remove (must be positive)
- **Returns**: `boolean` - Success status

### Job

#### `getJob(playerId)`
Gets the player's current job.
- **playerId**: `number` - The player's server ID
- **Returns**: `string` - Job