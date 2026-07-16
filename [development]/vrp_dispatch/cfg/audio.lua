local cfg = {}

-- ============================================================================
-- Voice Options
-- ============================================================================
cfg.voices = {
  male = {
    onyx  = "Onyx",
    echo  = "Echo",
    fable = "Fable",
    alloy = "Alloy"
  },
  female = {
    nova    = "Nova",
    shimmer = "Shimmer"
  }
}

cfg.speeds = {
  slow = 0.8,
  normal = 1.0,
  fast = 1.25
}

-- ============================================================================
-- Default Voice Settings
-- ============================================================================
cfg.defaults = {
  voice = "onyx",
  callsign = "Dispatch",
  speed = 1.0
}

-- ============================================================================
-- Event Voice Messages
-- ============================================================================
-- text     = realistic dispatch voice line
-- voice    = optional override voice
-- callsign = optional override callsign
-- speed    = optional override speed
cfg.events = {
  FOOT_SURRENDER = {
    text = "All units, be advised, suspect surrender reported. Police unit respond and secure scene.",
    voice = "onyx",
    callsign = "Dispatch",
    speed = 1.0
  },

  FOOT_INJURED = {
    text = "All units, be advised, injured subject reported. EMS respond and evaluate patient.",
    voice = "nova",
    callsign = "Dispatch",
    speed = 1.0
  },

  VEHICLE_SURRENDER = {
    text = "Attention units, vehicle stop with suspect surrender reported. Police respond and take subject into custody.",
    voice = "onyx",
    callsign = "Dispatch",
    speed = 1.0
  },

  VEHICLE_CRASH = {
    text = "Attention units, 10-50 motor vehicle accident reported. Fire and EMS respond.",
    voice = "nova",
    callsign = "Dispatch",
    speed = 1.0
  },

  SHOOTING = {
    text = "Attention all units, 10-32 shots fired reported. Police and EMS respond code three.",
    voice = "onyx",
    callsign = "Dispatch",
    speed = 1.0
  },

  FIGHT = {
    text = "All units, be advised, 10-11 fight in progress reported. Police respond.",
    voice = "onyx",
    callsign = "Dispatch",
    speed = 1.0
  },

  THEFT = {
    text = "All units, be advised, 10-31 theft reported. Police respond and investigate.",
    voice = "onyx",
    callsign = "Dispatch",
    speed = 1.0
  },

  ARMED_THEFT = {
    text = "Attention all units, 10-31 armed robbery in progress. Police and EMS respond code three.",
    voice = "onyx",
    callsign = "Dispatch",
    speed = 1.0
  },

  FIRE_VEHICLE = {
    text = "Attention units, vehicle fire reported. Fire and EMS respond immediately.",
    voice = "nova",
    callsign = "Dispatch",
    speed = 1.0
  },

  FIRE_PROPERTY = {
    text = "Attention units, property fire reported. Fire units respond immediately. Police stage for scene support.",
    voice = "nova",
    callsign = "Dispatch",
    speed = 1.0
  },

  INFO = {
    text = "All units, be advised, dispatch update follows.",
    voice = "onyx",
    callsign = "Dispatch",
    speed = 1.0
  }
}

return cfg