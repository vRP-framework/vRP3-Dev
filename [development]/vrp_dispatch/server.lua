local Dispatch = class("Dispatch", vRP.Extension)
Dispatch.tunnel = {}

-- ============================================================================
-- Constructor / Setup
-- ============================================================================

function Dispatch:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp_dispatch", "cfg/cfg")
  self.events = module("vrp_dispatch", "cfg/events")
  self.audio = module("vrp_dispatch", "cfg/audio")

  self.groupRoles = {}
  self.subMods = self.subMods or {}

  self.cityStatus = {}

  self.aiActive = {
    police = 0,
    ems = 0,
    fire = 0
  }

  self.incidents = {}
  self.nextIncidentId = 1

  self:getRoles()
  self:loadSubModules()
  self:registerDebugCommands()
  self:startIncidentCleanupLoop()
end

function Dispatch:log(msg)
  print("[vrp_dispatch] " .. tostring(msg))
end

-- ============================================================================
-- Debug Commands
-- ============================================================================

function Dispatch:registerDebugCommands()
  -- Shared server-side authorization for all debug/admin-only commands in this
  -- resource. Never trusts client input: the only identity source is
  -- vRP.users_by_source[source], where 'source' is the FiveM-assigned invoker id.
  -- requiresPlayer = true rejects source == 0 (server console) since those
  -- commands need a connected player's identity and/or in-game position.
  local function authorizeDebugCommand(name, source, requiresPlayer)
    if not self.cfg.debug then
      self:log(("Rejected debug command '%s' from source %s: cfg.debug is disabled"):format(
        name, tostring(source)
      ))
      return false
    end

    if source == 0 then
      if requiresPlayer then
        self:log(("Rejected debug command '%s' from server console: requires a connected player"):format(name))
        return false
      end
      return true, nil
    end

    local user = vRP.users_by_source[source]
    if not self:isDebugAdmin(user) then
      self:log(("Rejected debug command '%s' from source %s (user=%s): not authorized"):format(
        name, tostring(source), user and tostring(user.id) or "unknown"
      ))
      return false
    end

    return true, user
  end

  -- DEBUG: remove later
  RegisterCommand("getMap", function(source)
    local ok = authorizeDebugCommand("getMap", source, true)
    if not ok then return end

    vRP.EXT.Map.remote._getAllEntities(source)
  end, false)

  -- DEBUG: remove later
  RegisterCommand("radioDev", function(source)
    local ok = authorizeDebugCommand("radioDev", source, true)
    if not ok then return end

    self.remote._radioDev(source)
  end, false)

  -- DEBUG: remove later
  RegisterCommand("playAudio", function(source)
    local ok = authorizeDebugCommand("playAudio", source, true)
    if not ok then return end

    print("Testing playAudio command with sample data...")

    local data = {
      text = "This is a test message.",
      voice = "onyx",
      callsign = "Dispatch",
      speed = 1.0
    }

    self.remote._playRadioMessage(source, data)
  end, false)

  -- DEBUG: remove later
  RegisterCommand("testStart", function(source, args)
    local ok, user = authorizeDebugCommand("testStart", source, true)
    if not ok then return end

    local eventType = tostring(args[1] or "VEHICLE_CRASH")

    if not self:getEventConfig(eventType) then
      self:log(("testStart rejected: unknown event type '%s'"):format(eventType))
      return
    end

    self:log("testStart triggering event: " .. eventType)
    self:handleIncident(eventType, user, {
      vehicle = true
    })
  end, false)

  -- DEBUG: remove later
  RegisterCommand("testEnd", function(source, args)
    local ok = authorizeDebugCommand("testEnd", source, false)
    if not ok then return end

    if not args[1] then
      self:log("testEnd failed: no incident id or name provided")
      return
    end

    local incidentId = tonumber(args[1])
    if not incidentId or not self.incidents[incidentId] then
      self:log(("testEnd rejected: unknown incident id '%s'"):format(tostring(args[1])))
      return
    end

    self:log("Ending incident with input: " .. tostring(incidentId))
    self:clearIncident(incidentId)
  end, false)

  -- DEBUG: remove later
  RegisterCommand("testIncidents", function(source)
    local ok = authorizeDebugCommand("testIncidents", source, false)
    if not ok then return end

    print(json.encode(self.incidents))
  end, false)

  -- DEBUG: remove later
  RegisterCommand("resetAI", function(source)
    local ok = authorizeDebugCommand("resetAI", source, false)
    if not ok then return end

    self.aiActive = {
      police = 0,
      ems = 0,
      fire = 0
    }

    self:log("AI counters reset.")
  end, false)
end

-- ============================================================================
-- Role / Group Helpers
-- ============================================================================

function Dispatch:getRoles()
  for role, groups in pairs(self.cfg.groups.roles) do
    for _, group in ipairs(groups) do
      self.groupRoles[group] = role
    end
  end
end

function Dispatch:getUserRole(user)
  local defaultGroup = self.cfg.groups.default
  local groups = user:getGroups()
  local hasRole = nil

  for g in pairs(groups) do
    local role = self.groupRoles[g]
    if role then
      hasRole = role
      break
    end
  end

  if not hasRole then
    hasRole = defaultGroup
    user:addGroup(defaultGroup)
  end

  return hasRole
end

function Dispatch:getCounters()
  self.cityStatus = {}

  for role in pairs(self.cfg.groups.roles) do
    self.cityStatus[role] = 0
  end

  for _, user in pairs(vRP.users) do
    local role = self:getUserRole(user)
    self.cityStatus[role] = (self.cityStatus[role] or 0) + 1
  end
end

-- ============================================================================
-- Debug Admin Visibility
-- ============================================================================

function Dispatch:isDebugAdmin(user)
  if not user or not self.cfg.debug then
    return false
  end

  local groups = user:getGroups()

  for _, groupName in ipairs(self.cfg.debugGroups or {}) do
    if groups[groupName] then
      return true
    end
  end

  return false
end

function Dispatch:canUserReceiveEvent(user, targetRoles)
  if not user then
    return false
  end

  local userRole = self:getUserRole(user)

  if targetRoles and targetRoles[userRole] then
    return true
  end

  if self:isDebugAdmin(user) then
    return true
  end

  return false
end

-- ============================================================================
-- Event Config Helpers
-- ============================================================================

function Dispatch:getEventConfig(eventType)
  if self.events.incidents and self.events.incidents[eventType] then
    return self.events.incidents[eventType], "incident"
  end

  if self.events.non_incidents and self.events.non_incidents[eventType] then
    return self.events.non_incidents[eventType], "non_incident"
  end

  return nil, nil
end

function Dispatch:getEventTargetRoles(eventType)
  local eventCfg, eventClass = self:getEventConfig(eventType)
  local roles = {}

  if not eventCfg or not eventCfg.units then
    return roles
  end

  for _, unit in ipairs(eventCfg.units) do
    if unit.role then
      roles[unit.role] = true
    end
  end

  return roles
end

function Dispatch:getEventMarkerConfig(eventType)
  local eventCfg = self:getEventConfig(eventType)
  if not eventCfg then
    return clone(self.cfg.marker)
  end

  local markerCfg = clone(self.cfg.marker)

  if eventCfg.marker then
    for k, v in pairs(eventCfg.marker) do
      markerCfg[2][k] = v
    end
  end

  return markerCfg
end

function Dispatch:getEventPriorityLabel(eventType)
  local eventCfg = self:getEventConfig(eventType)
  if not eventCfg then
    return self.cfg.defaults.priorityLabels.info or "Info"
  end

  local priority = eventCfg.priority or "info"
  return self.cfg.defaults.priorityLabels[priority] or priority
end

-- ============================================================================
-- Audio / Voice Helpers
-- ============================================================================

function Dispatch:getEventAudioConfig(eventType)
  if self.audio and self.audio.events and self.audio.events[eventType] then
    return self.audio.events[eventType]
  end

  if self.audio and self.audio.events and self.audio.events.INFO then
    return self.audio.events.INFO
  end

  return nil
end

function Dispatch:getEventVoicePayload(eventType, msg)
  local audioCfg = self:getEventAudioConfig(eventType) or {}
  local defaults = self.audio.defaults or {}

  return {
    text = msg or audioCfg.text or "All units, be advised, dispatch update follows.",
    voice = audioCfg.voice or defaults.voice or "onyx",
    callsign = audioCfg.callsign or defaults.callsign or "Dispatch",
    speed = audioCfg.speed or defaults.speed or 1.0
  }
end

function Dispatch:playEventAudioForUser(user, eventType, msg)
  if not user then return end

  local voicePayload = self:getEventVoicePayload(eventType, msg)
  self.remote._playRadioMessage(user.source, voicePayload)

  if self.cfg.debug then
    self.remote._radio(user.source, msg)
  end
end

-- ============================================================================
-- Module System
-- ============================================================================

function Dispatch:subInit(user)
  for _, mod in pairs(self.subMods) do
    if mod.tunnel and mod.tunnel.init then
      mod.tunnel.init(user.source, user)
    end
  end
end

function Dispatch:emit(event, data)
  for _, mod in pairs(self.subMods) do
    if mod.onDispatchEvent then
      mod:onDispatchEvent(event, data)
    end
  end
end

function Dispatch:loadSubModules()
  for _, moduleName in ipairs(self.cfg.modules or {}) do
    local ok, err = pcall(function()
      local moduleClass = module("vrp_dispatch", "modules/" .. moduleName)
      self.subMods[moduleName] = moduleClass(self)
    end)

    if ok then
      if self.cfg.debug then
        self:log("Loaded module: " .. moduleName)
      end
    else
      self:log("Failed to load module: " .. tostring(err))
    end
  end
end

-- ============================================================================
-- Marker System
-- ============================================================================

function Dispatch:registerMarker(user, pos, markerCfg, opts)
  opts = opts or {}

  local prefix = opts.prefix
  local enter = opts.enter
  local leave = opts.leave

  local created = {}

  for k, v in pairs(pos) do
    local _, gtype, x, y, z = table.unpack(v)

    local ment = clone(markerCfg)
    ment[2].title = tostring(gtype)
    ment[2].pos = { x, y, z - 1 }

    local entityId = vRP.EXT.Map.remote.addEntity(user.source, ment[1], ment[2])
    created[k] = entityId

    if prefix then
      user:setArea("vRP:" .. prefix .. ":" .. k, x, y, z, 1, 1.5, enter, leave)
    end
  end

  return created
end

-- ============================================================================
-- Incident System
-- ============================================================================

function Dispatch:handleIncident(eventType, user, extra)
  if not user then return end

  local eventCfg, eventClass = self:getEventConfig(eventType)
  if not eventCfg then return end

  local x, y, z = vRP.EXT.Base.remote.getPosition(user.source)

  local payload = {
    event = eventType,
    user = user,
    source = user.source,
    coords = { x, y, z },
    extra = extra or {},
    createdAt = os.time()
  }

  local nearbyIncidentId, nearbyIncident = self:findNearbyIncident(eventType, payload.coords)
  if nearbyIncidentId then
    self:updateIncident(nearbyIncidentId, payload)

    if self.cfg.debug then
      self:log(("Merged event %s into nearby incident %s"):format(
        tostring(eventType),
        tostring(nearbyIncident.name or nearbyIncidentId)
      ))
    end

    return nearbyIncidentId
  end

  self:emit(eventType, payload)

  local incidentId = self:radioBroadcast(eventType, payload)
  if not incidentId then return nil end

  if self.cfg.debug then
    self:log(("Incident broadcasted: eventType=%s incidentId=%s"):format(
      tostring(eventType),
      tostring(incidentId)
    ))
  end

  if eventCfg.units then
    for _, unit in ipairs(eventCfg.units) do
      self:requestUnits(unit.role, unit.count, payload.coords, payload.extra, incidentId)
    end
  end

  return incidentId
end

-- Public dispatch API for modules/resources.
function Dispatch:reportIncident(eventType, user, extra)
  local user = user or vRP.users_by_source[source]

  print(("[vrp_dispatch] reportIncident called: eventType=%s user=%s"):format(
    tostring(eventType),
    tostring(user and user.id or "nil")
  ))

  return self:handleIncident(eventType, user, extra)
end

function Dispatch:radioBroadcast(event, data)
  local eventCfg, eventClass = self:getEventConfig(event)
  if not eventCfg then return end

  local audioCfg = self:getEventAudioConfig(event) or {}
  local msg = data.msg or audioCfg.text or eventCfg.msg or ""
  local targetRoles = self:getEventTargetRoles(event)

  if self.cfg.defaults.autoAnnounce then
    for _, user in pairs(vRP.users) do
      if eventClass == "non_incident" then
        local roles = { police = true, ems = true, fire = true }

        if self:canUserReceiveEvent(user, roles) then
          self:playEventAudioForUser(user, event, msg)
        end
      elseif self:canUserReceiveEvent(user, targetRoles) then
        self:playEventAudioForUser(user, event, msg)
      end
    end
  end

  if eventClass == "incident" then
    return self:addIncident(event, data)
  end
end

function Dispatch:addIncident(event, data)
  local id = self.nextIncidentId
  self.nextIncidentId = id + 1

  local x, y, z = table.unpack(data.coords)
  local name = string.format("%s_%d", event, id)
  local targetRoles = self:getEventTargetRoles(event)
  local eventCfg = self:getEventConfig(event)
  local markerCfg = self:getEventMarkerConfig(event)
  local priorityLabel = self:getEventPriorityLabel(event)

  local incident = {
    id = id,
    name = name,
    event = event,
    coords = { x, y, z },
    source = data.source,
    createdAt = data.createdAt or os.time(),
    updatedAt = data.createdAt or os.time(),
    reports = 1,
    state = "pending",
    priority = eventCfg and eventCfg.priority or "info",
    priorityLabel = priorityLabel,
    assigned = {
      police = 0,
      ems = 0,
      fire = 0
    },
    requested = {},
    responders = {},
    entities = {},
    extra = data.extra or {}
  }

  if eventCfg and eventCfg.units then
    for _, unit in ipairs(eventCfg.units) do
      incident.requested[unit.role] = (incident.requested[unit.role] or 0) + unit.count
    end
  end

  self.incidents[id] = incident

  for _, user in pairs(vRP.users) do
    if self:canUserReceiveEvent(user, targetRoles) then
      local pos = {
        { name, string.format("%s | %s", priorityLabel, name), x, y, z }
      }

      local entityMap = self:registerMarker(user, pos, markerCfg)
      incident.entities[user.source] = entityMap[1]
    end
  end

  self:log(string.format("Incident created: %s (%s)", name, priorityLabel))
  return id
end

function Dispatch:assignUnitsToIncident(incidentId, role, count, responderData)
  local incident = self.incidents[tonumber(incidentId)]
  if not incident then
    self:log("assignUnitsToIncident failed: incident not found " .. tostring(incidentId))
    return false
  end

  count = tonumber(count) or 0
  if count <= 0 then
    self:log("assignUnitsToIncident failed: invalid count")
    return false
  end

  incident.assigned[role] = (incident.assigned[role] or 0) + count

  if responderData then
    incident.responders[role] = incident.responders[role] or {}
    table.insert(incident.responders[role], responderData)
  end

  if incident.state == "pending" then
    incident.state = "assigned"
  end

  self:log(string.format(
    "Assigned %d %s unit(s) to incident %s",
    count, tostring(role), tostring(incidentId)
  ))

  return true
end

function Dispatch:setIncidentOnScene(incidentId, role)
  local incident = self.incidents[tonumber(incidentId)]
  if not incident then return false end

  incident.state = "onscene"
  self:log(string.format(
    "Incident %s marked on scene by %s",
    tostring(incidentId),
    tostring(role)
  ))
  return true
end

function Dispatch:clearIncident(incidentId)
  local incident = self.incidents[tonumber(incidentId)]
  if not incident then
    self:log("clearIncident failed: incident not found " .. tostring(incidentId))
    return false
  end

  incident.state = "cleared"

  for source, entityId in pairs(incident.entities or {}) do
    if entityId then
      vRP.EXT.Map.remote._removeEntity(source, entityId)
    end
  end

  self.incidents[tonumber(incidentId)] = nil
  self:log("Incident cleared: " .. tostring(incidentId))
  return true
end

function Dispatch:removeIncident(input)
  local entityId = tonumber(input)
  local removed = false
  local matchedIncidentId = nil

  if self.cfg.debug then
    self:log(string.format(
      "removeIncident called: input=%s type=%s entityId=%s",
      tostring(input),
      type(input),
      tostring(entityId)
    ))
  end

  if entityId then
    for incidentId, incident in pairs(self.incidents or {}) do
      for _, storedEntityId in pairs(incident.entities or {}) do
        if storedEntityId == entityId then
          matchedIncidentId = incidentId
          break
        end
      end

      if matchedIncidentId then
        break
      end
    end
  end

  for _, user in pairs(vRP.users) do
    local targetEntityId = entityId

    if not targetEntityId then
      targetEntityId = vRP.EXT.Map.remote.getEntityByName(user.source, input)
    end

    if targetEntityId then
      vRP.EXT.Map.remote._removeEntity(user.source, targetEntityId)
      removed = true
    end
  end

  if type(input) == "string" then
    local incidentId = tonumber(input:match("_(%d+)$"))
    if incidentId and self.incidents[incidentId] then
      self.incidents[incidentId] = nil
    end
  end

  if matchedIncidentId and self.incidents[matchedIncidentId] then
    self.incidents[matchedIncidentId] = nil
  end

  if removed then
    self:log("Removed incident: " .. tostring(input))
    return true
  end

  self:log("Failed to remove incident: " .. tostring(input))
  return false
end

function Dispatch:updateIncident(incidentId, data)
  local incident = self.incidents[tonumber(incidentId)]
  if not incident then
    self:log("updateIncident failed: incident not found " .. tostring(incidentId))
    return false
  end

  incident.updatedAt = os.time()
  incident.lastSource = data.source or incident.lastSource
  incident.extra = data.extra or incident.extra
  incident.reports = (incident.reports or 1) + 1

  local moved = false

  if data.coords then
    local oldCoords = incident.coords or {0, 0, 0}
    local distance = self:getDistanceBetweenCoords(oldCoords, data.coords)
    local minMoveDistance = (self.cfg.incidentMerge and self.cfg.incidentMerge.minMoveDistance) or 10.0

    if distance > minMoveDistance then
      moved = true
      incident.coords = {
        data.coords[1],
        data.coords[2],
        data.coords[3]
      }
    end
  end

  if moved and incident.coords then
    local x, y, z = table.unpack(incident.coords)
    local markerCfg = self:getEventMarkerConfig(incident.event)
    local targetRoles = self:getEventTargetRoles(incident.event)

    for _, user in pairs(vRP.users) do
      if self:canUserReceiveEvent(user, targetRoles) then
        local oldEntityId = incident.entities[user.source]
        if oldEntityId then
          vRP.EXT.Map.remote._removeEntity(user.source, oldEntityId)
          incident.entities[user.source] = nil
        end

        local pos = {
          { incident.name, incident.name, x, y, z }
        }

        local entityMap = self:registerMarker(user, pos, markerCfg)
        incident.entities[user.source] = entityMap[1]
      end
    end

    local updateMsg = self:getIncidentUpdateMessage(incident)

    for _, user in pairs(vRP.users) do
      if self:canUserReceiveEvent(user, targetRoles) then
        self:playEventAudioForUser(user, "INFO", updateMsg)
      end
    end
  end

  if self.cfg.debug then
    self:log(("Incident updated: %s reports=%d moved=%s"):format(
      tostring(incident.name),
      tonumber(incident.reports or 1),
      tostring(moved)
    ))
  end

  return true
end

function Dispatch:getIncidentUpdateMessage(incident)
  if not incident then
    return "All units, be advised, incident location updated."
  end

  local eventCfg, _ = self:getEventConfig(incident.event)
  local code = eventCfg and eventCfg.code or "incident"

  return string.format(
    "All units, be advised, %s incident location updated. Respond to updated location.",
    code
  )
end

function Dispatch:getDistanceBetweenCoords(a, b)
  if not a or not b then return math.huge end

  local ax, ay, az = a[1] or 0, a[2] or 0, a[3] or 0
  local bx, by, bz = b[1] or 0, b[2] or 0, b[3] or 0

  local dx = ax - bx
  local dy = ay - by
  local dz = az - bz

  return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Dispatch:findNearbyIncident(eventType, coords)
  local mergeCfg = self.cfg.incidentMerge or {}
  if not mergeCfg.enabled then return nil, nil end

  local radius = mergeCfg.radius or 10.0

  for incidentId, incident in pairs(self.incidents or {}) do
    if incident.event == eventType and incident.state ~= "cleared" then
      local distance = self:getDistanceBetweenCoords(coords, incident.coords)

      if distance <= radius then
        return incidentId, incident
      end
    end
  end

  return nil, nil
end

-- ============================================================================
-- Incident Sync / Clear
-- ============================================================================

function Dispatch:syncIncidentsForUser(user)
  if not user then return false end

  self:clearIncidentsForUser(user)

  local synced = false

  for _, incident in pairs(self.incidents) do
    local targetRoles = self:getEventTargetRoles(incident.event)

    if self:canUserReceiveEvent(user, targetRoles) then
      local x, y, z = table.unpack(incident.coords)
      local markerCfg = self:getEventMarkerConfig(incident.event)

      local pos = {
        { incident.name, incident.name, x, y, z }
      }

      local entityMap = self:registerMarker(user, pos, markerCfg)
      incident.entities[user.source] = entityMap[1]
      synced = true
    end
  end

  return synced
end

function Dispatch:clearIncidentsForUser(user)
  if not user then return false end

  for _, incident in pairs(self.incidents) do
    local entityId = incident.entities[user.source]

    if entityId then
      vRP.EXT.Map.remote._removeEntity(user.source, entityId)
      incident.entities[user.source] = nil
    end
  end

  return true
end

-- ============================================================================
-- AI System
-- ============================================================================

function Dispatch:getAvailableAI(role)
  self:getCounters()

  local citizens = self.cityStatus.citizen or 0
  local realUnits = self.cityStatus[role] or 0

  local target = math.floor((citizens + realUnits) * self.cfg.defaults.aiPercentage)
  target = math.max(target, self.cfg.defaults.aiMinimum)
  target = math.min(target, self.cfg.defaults.aiMaximum)

  local active = self.aiActive[role] or 0
  return math.max(target - active, 0)
end

function Dispatch:requestUnits(role, count, coords, context, incidentId)
  local available = self:getAvailableAI(role)
  local send = math.min(count, available)

  if send <= 0 then
    self:radioBroadcast("INFO", {
      coords = coords,
      msg = "All units be advised, " .. string.upper(role) .. " currently unavailable.",
      extra = context
    })
    return 0
  end

  self.aiActive[role] = (self.aiActive[role] or 0) + send

  if incidentId then
    self:assignUnitsToIncident(incidentId, role, send, {
      type = "ai",
      count = send
    })
  end

  self:emit("AI_REQUEST_" .. string.upper(role), {
    incidentId = incidentId,
    role = role,
    count = send,
    coords = coords,
    extra = context
  })

  return send
end

function Dispatch:releaseUnit(role, count)
  count = tonumber(count) or 1
  self.aiActive[role] = math.max((self.aiActive[role] or 0) - count, 0)
end

-- ============================================================================
-- Incident Cleanup
-- ============================================================================

function Dispatch:startIncidentCleanupLoop()
  local cleanupCfg = self.cfg.incidentCleanup or {}
  if not cleanupCfg.enabled then
    return
  end

  local intervalMs = math.max((cleanupCfg.interval or 60) * 1000, 1000)

  local function tick()
    self:cleanupIncidents()

    SetTimeout(intervalMs, function()
      tick()
    end)
  end

  tick()
end

function Dispatch:cleanupIncidents()
  local cleanupCfg = self.cfg.incidentCleanup or {}
  if not cleanupCfg.enabled then
    return
  end

  local staleAfter = cleanupCfg.staleAfter or 600
  local now = os.time()

  for incidentId, incident in pairs(self.incidents or {}) do
    local lastUpdate = incident.updatedAt or incident.createdAt or now
    local age = now - lastUpdate

    if incident.state ~= "cleared" and age >= staleAfter then
      if self.cfg.debug then
        self:log(("Auto-clearing stale incident %s after %d seconds of inactivity"):format(
          tostring(incident.name or incidentId),
          tonumber(age)
        ))
      end

      self:clearIncident(incidentId)
    end
  end
end

-- ============================================================================
-- Framework Events
-- ============================================================================

Dispatch.event = {}

function Dispatch.event:playerSpawn(user, first)
  if first then
    self:getCounters()
    self:subInit(user)
    self:syncIncidentsForUser(user)
  end
end

function Dispatch.event:playerLeave(user)
  self:clearIncidentsForUser(user)

  SetTimeout(1000, function()
    self:getCounters()
  end)
end

function Dispatch.event:playerDeath(user)
  local inVeh = vRP.EXT.Vehicle.remote.isInVehicle(user.source)

  if inVeh then
    self:handleIncident("VEHICLE_CRASH", user, {
      vehicle = true
    })
      return
  end

  self:handleIncident("FOOT_INJURED", user)
end

function Dispatch.event:playerJoinGroup(user)
  self:syncIncidentsForUser(user)
end

function Dispatch.event:playerLeaveGroup(user)
  self:clearIncidentsForUser(user)
end

vRP:registerExtension(Dispatch)