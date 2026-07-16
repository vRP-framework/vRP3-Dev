local cfg = {}

cfg.incidents = {
  FOOT_SURRENDER = {
    msg = "All units, be advised, suspect surrender reported. Police respond and secure scene.",
    code = "10-15",
    priority = "medium",
    marker = { blip_color = 17 },
    units = {
      { role = "police", count = 2 }
    }
  },

  FOOT_INJURED = {
    msg = "All units, be advised, injured subject reported. EMS respond and evaluate patient.",
    code = "10-52",
    priority = "priority",
    marker = { blip_color = 2 },
    units = {
      { role = "ems", count = 1 }
    }
  },

  VEHICLE_SURRENDER = {
    msg = "All units, be advised, vehicle stop with suspect surrender reported. Police respond.",
    code = "10-15",
    priority = "medium",
    marker = { blip_color = 17 },
    units = {
      { role = "police", count = 3 }
    }
  },

  VEHICLE_CRASH = {
    msg = "All units, be advised, 10-50 motor vehicle accident reported. Fire and EMS respond.",
    code = "10-50",
    priority = "priority",
    marker = { blip_color = 47 },
    units = {
      { role = "fire", count = 1 },
      { role = "ems", count = 2 }
    }
  },

  SHOOTING = {
    msg = "All units, be advised, 10-32 shots fired reported. Police and EMS respond code three.",
    code = "10-32",
    priority = "emergency",
    marker = { blip_color = 1 },
    units = {
      { role = "police", count = 4 },
      { role = "ems", count = 1 }
    }
  },

  FIGHT = {
    msg = "All units, be advised, 10-11 fight in progress reported. Police respond.",
    code = "10-11",
    priority = "medium",
    marker = { blip_color = 17 },
    units = {
      { role = "police", count = 2 }
    }
  },

  THEFT = {
    msg = "All units, be advised, 10-31 theft reported. Police respond and investigate.",
    code = "10-31",
    priority = "medium",
    marker = { blip_color = 5 },
    units = {
      { role = "police", count = 2 }
    }
  },

  ARMED_THEFT = {
    msg = "All units, be advised, 10-31 armed robbery in progress. Police and EMS respond code three.",
    code = "10-31",
    priority = "emergency",
    marker = { blip_color = 1 },
    units = {
      { role = "police", count = 4 },
      { role = "ems", count = 1 }
    }
  }
}

cfg.non_incidents = {
  INFO = {
    msg = "All units, be advised, dispatch update follows."
  }
}

return cfg