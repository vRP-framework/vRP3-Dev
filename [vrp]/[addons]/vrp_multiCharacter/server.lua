local lang = vRP.lang
local Multi = class("Multi_Character", vRP.Extension)
Multi.event = {}
Multi.tunnel = {}

function Multi:__construct()
    vRP.Extension.__construct(self)

    self.cfg = module("vrp_multiCharacter", "cfg/multiCharacter")

  -- Register the server event to open the Multi Character Menu
  RegisterServerEvent("Multi:open")
  AddEventHandler("Multi:open", function()
    self.remote._open(source)
  end)

  -- player/ ai based commands
	RegisterCommand("character", function(source, args, rawCommand)
    self.remote._intiSkyCam(source)
    self.remote._spawnPlayer(source, 1)
    
    SetTimeout(1000,function()
      self.remote._open(source, 6)
    end)
	end, false)


  async(function()
    -- Alter table to add gender column
    vRP:prepare("vRP/add_gender_column", [[
      ALTER TABLE vrp_character_identities 
      ADD COLUMN IF NOT EXISTS gender VARCHAR(10) DEFAULT 'n/a' NOT NULL
    ]])

    -- Prepare the modified insert and update statements
    vRP:prepare("vRP/init_character_identity",
      "INSERT IGNORE INTO vrp_character_identities(character_id, registration, phone, firstname, name, age, gender) " ..
      "VALUES(@character_id, @registration, @phone, @firstname, @name, @age, @gender)"
    )
    vRP:prepare("vRP/update_character_identity",
      "UPDATE vrp_character_identities SET firstname = @firstname, name = @name, age = @age, " ..
      "registration = @registration, phone = @phone, gender = @gender WHERE character_id = @character_id"
    )
    vRP:execute("vRP/add_gender_column") 
  end)
end

function Multi.event:playerSpawn(user, first_spawn)
  if first_spawn and user:isReady() then  -- Ensure it's the first spawn and user is ready
    local delay = self.cfg.loading and 0 or 2000  -- Set delay based on loading state

    SetTimeout(delay, function()   -- Open after delay
      self.remote._open(user.source)
    end)
  end
end

function Multi:create(user, data)   -- createIdentity
  -- Attempt to create the character
  if not user:createCharacter() then
    vRP.EXT.Base.remote._notify(user.source, lang.characters.create.error())
    return
  end

  -- Get all character IDs for the user once
  local characters = user:getCharacters()
  local userCid = user.cid

  -- Prepare data if it's not provided
  if not data then
    data = self:createIdentity(user)
    if not data then return end  -- Exit if input validation failed
  end

  -- Loop through characters and create missing identities
  for _, cid in ipairs(characters) do
    -- Skip if this is the user's current character
    if cid ~= userCid then
      local identity = vRP.EXT.Identity:getIdentity(cid)

      -- Only create identity if it doesn't exist
      if not identity then
        -- Insert new identity into the database
        vRP:execute("vRP/init_character_identity", {
          character_id = cid,
          registration = vRP.EXT.Identity:generateRegistrationNumber(),
          phone = vRP.EXT.Identity:generatePhoneNumber(),
          firstname = data.firstname,
          name = data.name,
          gender = data.gender,
          age = data.age
        })
      end
    end
  end
end

function Multi:changeModel(gender)
  -- Pre-determine the model based on gender
  local modelConfig = (gender == "female") and self.cfg.default_customization.female.customizations or self.cfg.default_customization.male.customizations

  -- Iterate over all users once, and only update when necessary
  for _, user in pairs(vRP.users) do
    local customization = user.cdata.state.customization or modelConfig

    if user.cdata.state.customization then -- customization
      vRP.EXT.PlayerState.remote._setCustomization(user.source, user.cdata.state.customization) 
      return
    end

    -- default customization
    if not user.cdata.state.customization then
      user.cdata.state.customization = modelConfig
    end

    -- Apply the updated customization
    vRP.EXT.PlayerState.remote._setCustomization(user.source, customization)
  end
end

function Multi:createCharacter(data)
  -- Validate incoming data early to avoid unnecessary processing
  if not data or not data.name or not data.age or not data.gender then return end

  -- Split name and ensure both parts are set
  local charName = splitString(data.name, ' ')
  local firstname, name = charName[1] or "Unknown", charName[2] or ""

  -- Prepare the character data to create
  local charData = {
    firstname = firstname,
    name = name,
    age = data.age,
    gender = data.gender
  }

  -- Create the character for each user
  for _, user in pairs(vRP.users) do
    self:create(user, charData)
    --vRP.EXT.Identity:createCharacter(user, charData)
  end

  -- Refresh character list only once after creating characters
  self:getCharacters(data)
end


function Multi:deleteCharacter(data)
  -- Retrieve the selected character by registration
  local selectedChar = vRP.EXT.Identity:getByRegistration(data.registration)
  if not selectedChar then return end  -- Exit early if no matching character

  -- Iterate over users to find and delete the selected character
  for _, user in pairs(vRP.users) do
    local characters = user:getCharacters()

    -- Process each character until the selected one is deleted
    for _, cid in ipairs(characters) do
      if cid ~= selectedChar then -- Skip if it's the selected character
        local identity = vRP.EXT.Identity:getIdentity(cid)
        if identity then
          user:useCharacter(cid, true) -- Switch character
          self:changeModel(identity.gender) -- Update model based on gender
          user:deleteCharacter(selectedChar) -- Delete the selected character

          break -- Once the character is deleted, no need to loop further for this user
        end
      end
    end
  end

  self:getCharacters()  -- refresh characters
end


function Multi:selectCharacter(data)
  -- Retrieve necessary data
  local registration, gender = data.registration, data.gender
  local identity = vRP.EXT.Identity:getByRegistration(registration)
  if not identity then return end  -- Exit if identity is not found

  -- Process each user for character selection
  for _, user in pairs(vRP.users) do
    local characters = user:getCharacters()
    local current_cid = user.cid

    -- Process each character, only if not the currently used one
    for _, cid in ipairs(characters) do
      local identity = vRP.EXT.Identity:getIdentity(cid)

      if identity and identity.registration == registration then
        -- Attempt to use character and handle potential errors
        local ok, err = user:useCharacter(cid, true)
        -- Get the group data based on the configuration
        local group = self.cfg.vRP_groups and self.cfg.groups or vRP.EXT.Group.cfg.groups     


        if ok then
          self:changeModel(gender)  -- Change model if no errors occurred

          for groupName, cfg in pairs(group) do
            -- Skip if the group is not a job or if the user already has the group
            if cfg._config.gtype == "job" and user:hasGroup(groupName) then return end

            -- Default values for group title and name
            if cfg._config and cfg._config.default then
              -- Ensure user has the job group and add it if missing
              user:addGroup(groupName)
            end
          end
        else
          -- Notify user of any errors
          local msg

          if err <= 2 then
            msg = lang.common.must_wait({ user.use_character_action:remaining() })
          else
            msg = lang.characters.character.error()
          end
          
          vRP.EXT.Base.remote._notify(user.source, msg)
        end
      end
    end
  end
end 

function Multi:getCharacters(data)

  -- Helper function to check if a character already exists in charData
  local function characterExists(charData, charInfo)
    for _, char in ipairs(charData) do
      if char.name == charInfo.name and char.age == charInfo.age then
        return true
      end
    end
    return false
  end

  -- Cache configuration variables used in the loop for faster access
  local groupsConfig = self.cfg.vRP_groups and self.cfg.groups or vRP.EXT.Group.cfg.groups
  local defaultWallet = vRP.EXT.Money.cfg.open_wallet or 0
  local defaultBank = vRP.EXT.Money.cfg.open_bank or 0

  -- Iterate over all users
  for _, user in pairs(vRP.users) do
    local charData = {}  -- Initialize charData for this user
    local characters = user:getCharacters()

    -- Process each character
    for _, cid in ipairs(characters) do
      local identity = vRP.EXT.Identity:getIdentity(cid)
      local sdata = vRP:getCData(cid, "vRP:datatable")
      local data = sdata and msgpack.unpack(sdata) or {}  -- Unpack only if sdata exists

      local groupTitle = nil
      -- Check for the job title once and break early if found
      for groupName, cfg in pairs(groupsConfig) do
        if cfg._config then
          if cfg._config.default and not groupTitle then
            groupTitle = cfg._config.title or "Unknown"
          end
          if cfg._config.gtype == "job" and data.groups and data.groups[groupName] then
            groupTitle = cfg._config.title
            break
          end
        end
      end

      if identity then
        -- Prepare character data
        local charInfo = {
          name = (identity.firstname or "Unknown") .. " " .. (identity.name or "Unknown"),
          age = identity.age or "n/a",
          gender =  identity.gender or "n/a",  
          job = groupTitle,
          rank = "n/a",
          cash = data.wallet or defaultWallet,
          bank = data.bank or defaultBank,
          phone = identity.phone or "n/a",
          registration = identity.registration or "n/a",
        }

        -- Insert character data only if it doesn't exist
        if not characterExists(charData, charInfo) then
          table.insert(charData, charInfo)
        end
      end
    end

    -- Update character data for this user
    self.remote._updateChars(user.source, charData)
  end
end

function Multi:getLocations()
  local user = vRP.users_by_source[source]
  local spawnList = {}

  -- Insert "last location" first if it exists in cfg.spawn
  if self.cfg.spawn["last location"] and user.cdata.state.position then
    table.insert(spawnList, self.cfg.spawn["last location"])
  end

  -- Insert the remaining locations
  for key, location in pairs(self.cfg.spawn) do
    if key ~= "last location" then
      table.insert(spawnList, location)
    end
  end

  -- Update location data for this user
  self.remote._updateLocations(user.source, spawnList)
end

function Multi:getLocations()
  local user = vRP.users_by_source[source]
  local spawnList = {}

  -- Check if "last location" exists and if the user has a valid position
  if self.cfg.spawn["last location"] and user.cdata.state.position then
    -- Add the user's current position as coordinates for "last location"
    local lastLocation = self.cfg.spawn["last location"]
    local data = user.cdata.state
    
    -- Assuming user.cdata.state.position is a vector with x, y, z, heading values
    lastLocation.coords = vector4(data.position.x, data.position.y, data.position.z, data.heading or 0)

    -- Insert "last location" into the spawn list
    table.insert(spawnList, lastLocation)
  end

  -- Insert the remaining locations
  for key, location in pairs(self.cfg.spawn) do
    if key ~= "last location" then
      table.insert(spawnList, location)
    end
  end

  -- Update location data for this user
  self.remote._updateLocations(user.source, spawnList)
end


Multi.tunnel.createCharacter = Multi.createCharacter
Multi.tunnel.deleteCharacter = Multi.deleteCharacter
Multi.tunnel.selectCharacter = Multi.selectCharacter
Multi.tunnel.getCharacters = Multi.getCharacters
Multi.tunnel.getLocations = Multi.getLocations

vRP:registerExtension(Multi)