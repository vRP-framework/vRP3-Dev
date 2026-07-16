local cfg = {}

-- ============================================================================
-- Debug / Admin
-- ============================================================================

cfg.debug = true

cfg.debugGroups = {
  "admin",
  "superadmin"
}

-- Load from server.cfg:
-- setr vrp_dispatch_openai_api_key "your_key_here"
cfg.openAIApiKey = ""
--cfg.openAIApiKey = GetConvar("vrp_dispatch_openai_api_key", "")

-- ============================================================================
-- Core Marker Defaults
-- ============================================================================

cfg.marker = {
  "PoI", {
    blip_id = 161,
    blip_color = 1
  }
}

-- ============================================================================
-- Incident Merge / Cleanup
-- ============================================================================

cfg.incidentMerge = {
  enabled = true,
  radius = 50.0,
  minMoveDistance = 10.0 -- minimum movement before an existing incident is considered moved
}

cfg.incidentCleanup = {
  enabled = true,
  interval = 60,   -- seconds between cleanup checks
  staleAfter = 600 -- seconds since last update before auto-clear
}

cfg.blockedIncidentTypes = {
  INFO = true,
  STATUS = true,
  WEATHER = true,
  DEBUG = true
}

-- ============================================================================
-- Module Loading
-- ============================================================================

cfg.modules = {
  "police",
  "fire",
  "ems"
}

-- ============================================================================
-- Dispatch / AI Defaults
-- ============================================================================

cfg.defaults = {
  voice = "female",
  voiceRate = 1.25,

  autoAnnounce = true,
  jailAfterHospital = false,

  -- AI staffing model
  aiPercentage = 0.2,
  aiMinimum = 2,
  aiMaximum = 20,

  aiLimitsPerCall = {
    police = 5,
    fire = 3,
    ems = 3,
    air = 1
  },

  priorityLabels = {
    nuclear = "Nuclear",
    emergency = "Emergency",
    priority = "Priority",
    medium = "Alert",
    info = "Info"
  }
}

-- Backward-compatible alias if other code still expects this at root
cfg.jailAfterHospital = cfg.defaults.jailAfterHospital

-- ============================================================================
-- Role / Group Mapping
-- ============================================================================

cfg.groups = {
  default = "citizen",

  roles = {
    police = {
      "police",
      "sheriff",
      "state"
    },
    ems = {
      "ems",
      "paramedic",
      "emergency"
    },
    fire = {
      "fire"
    },
    citizen = {
      "citizen"
    }
  }
}

return cfg