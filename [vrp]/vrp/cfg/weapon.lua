-- components list https://wiki.rage.mp/index.php?title=Weapons_Components
local cfg = {}

cfg.types = {
	["GROUP_RIFLE"] = {_config = {title = "Assult", enabled = true}},
	["GROUP_HEAVY"] = {_config = {title = "Heavy", enabled = true}},
	["GROUP_MG"] = {_config = {title = "Light", enabled = true}},
	["GROUP_MELEE"] = {_config = {title = "Melee", enabled = true}},
	["GROUP_MISC"] = {_config = {title = "Miscellaneous", enabled = true}},
	["GROUP_PISTOL"] = {_config = {title = "Pistol", enabled = true}},
	["GROUP_SHOTGUN"] = {_config = {title = "Shotguns", enabled = true}},
	["GROUP_SNIPER"] = {_config = {title = "Snipers", enabled = true}},
	["GROUP_SMG"] = {_config = {title = "SMG", enabled = true}},
	["GROUP_THROWN"] = {_config = {title = "Throwables", enabled = true}},
}

cfg.weapons = {	
  ["94989220"] = {
    HashKey = "WEAPON_COMBATSHOTGUN",
    Name = "Combat Shotgun",
    Description = "There's only one semi-automatic shotgun with a fire rate that sets the LSFD alarm bells ringing, and you're looking at it.",
    Group = "GROUP_SHOTGUN",
    Enabled = true,
    Components = {
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = false,
      },
      ["2205435306"] = {
        HashKey = "COMPONENT_AT_AR_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3323278933"] = {
        HashKey = "COMPONENT_COMBATSHOTGUN_CLIP_01",
        Name = "Default Shells",
        Description = "Standard shotgun ammunition.",
        Enabled = true
      }
    },
  },
  ["100416529"] = {
    HashKey = "WEAPON_SNIPERRIFLE",
    Name = "Sniper Rifle",
    Description = "Standard sniper rifle. Ideal for situations that require accuracy at long range. Limitations include slow reload speed and very low rate of fire.",
    Group = "GROUP_SNIPER",
    Enabled = true,
    Components = {
      ["2613461129"] = {
        HashKey = "COMPONENT_SNIPERRIFLE_CLIP_01",
        Name = "Default Clip",
        Description = "",
        IsDefault = true
      },
      ["2805810788"] = {
        HashKey = "COMPONENT_AT_AR_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3159677559"] = {
        HashKey = "COMPONENT_AT_SCOPE_MAX",
        Name = "Advanced Scope",
        Description = "Maximum zoom functionality.",
        IsDefault = true
      },
      ["3527687644"] = {
        HashKey = "COMPONENT_AT_SCOPE_LARGE",
        Name = "Scope",
        Description = "Long-range zoom functionality.",
        IsDefault = true
      }
    },
  },
  ["101631238"] = {
    HashKey = "WEAPON_FIREEXTINGUISHER",
    Name = "Fire Extinguisher",
    Description = "",
    Group = "GROUP_MISC",
    Enabled = true,
    Components = { },
  },
  ["125959754"] = {
    HashKey = "WEAPON_COMPACTLAUNCHER",
    Name = "Compact Grenade Launcher",
    Description = "Focus groups using the regular model suggested it was too accurate and found it awkward to use with one hand on the throttle. Easy fix. Part of Bikers.",
    Group = "GROUP_HEAVY",
    Enabled = true,
    Components = {
      ["1235472140"] = {
        HashKey = "COMPONENT_COMPACTLAUNCHER_CLIP_01",
        Name = "Default Clip",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["126349499"] = {
    HashKey = "WEAPON_SNOWBALL",
    Name = "Snowball",
    Description = "",
    Group = "GROUP_THROWN",
    Enabled = true,
    Components = { },
  },
  ["137902532"] = {
    HashKey = "WEAPON_VINTAGEPISTOL",
    Name = "Vintage Pistol",
    Description = "What you really need is a more recognizable gun. Stand out from the crowd at an armed robbery with this engraved pistol. Part of The \"I'm Not a Hipster\" Update.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["867832552"] = {
        HashKey = "COMPONENT_VINTAGEPISTOL_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Vintage Pistol.",
        Enabled = true,
      },
      ["1168357051"] = {
        HashKey = "COMPONENT_VINTAGEPISTOL_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Vintage Pistol.",
        IsDefault = true
      },
      ["3271853210"] = {
        HashKey = "COMPONENT_AT_PI_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      }
    },
  },
  ["171789620"] = {
    HashKey = "WEAPON_COMBATPDW",
    Name = "Combat PDW",
    Description = "Who said personal weaponry couldn't be worthy of military personnel? Thanks to our lobbyists, not Congress. Integral suppressor. Part of the Ill-Gotten Gains Update Part 1.",
    Group = "GROUP_SMG",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["860508675"] = {
        HashKey = "COMPONENT_COMBATPDW_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Combat PDW.",
        Enabled = true,
      },
      ["1125642654"] = {
        HashKey = "COMPONENT_COMBATPDW_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Combat PDW.",
        IsDefault = true
      },
      ["1857603803"] = {
        HashKey = "COMPONENT_COMBATPDW_CLIP_03",
        Name = "Drum Magazine",
        Description = "Expanded capacity and slower reload.",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2855028148"] = {
        HashKey = "COMPONENT_AT_SCOPE_SMALL",
        Name = "Scope",
        Description = "Medium-range zoom functionality.",
        Enabled = true,
      }
    },
  },
  ["177293209"] = {
    HashKey = "WEAPON_HEAVYSNIPER_MK2",
    Name = "Heavy Sniper Mk II",
    Description = "Far away, yet always intimate: if you're looking for a secure foundation for that long-distance relationship, this is it.",
    Group = "GROUP_SNIPER",
    Enabled = true,
    Components = {
      ["247526935"] = {
        HashKey = "COMPONENT_HEAVYSNIPER_MK2_CLIP_INCENDIARY",
        Name = "Incendiary Rounds",
        Description = "Bullets which set targets on fire when shot. Reduced capacity.",
        AmmoType = "AMMO_SNIPER_INCENDIARY",
        Enabled = true,
      },
      ["277524638"] = {
        HashKey = "COMPONENT_AT_SR_BARREL_02",
        Name = "Heavy Barrel",
        Description = "Increases damage dealt to long-range targets.",
        Enabled = true,
      },
      ["752418717"] = {
        HashKey = "COMPONENT_HEAVYSNIPER_MK2_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for regular ammo.",
        Enabled = true,
      },
      ["776198721"] = {
        HashKey = "COMPONENT_AT_SCOPE_THERMAL",
        Name = "Thermal Scope",
        Description = "Long-range zoom with toggleable thermal vision.",
        Enabled = true,
      },
      ["1005144310"] = {
        HashKey = "COMPONENT_HEAVYSNIPER_MK2_CLIP_FMJ",
        Name = "Full Metal Jacket Rounds",
        Description = "Increased damage to vehicles. Also penetrates bullet resistant and bulletproof vehicle glass. Reduced capacity.",
        AmmoType = "AMMO_SNIPER_FMJ",
        Enabled = true,
      },
      ["1602080333"] = {
        HashKey = "COMPONENT_AT_MUZZLE_08",
        Name = "Squared Muzzle Brake",
        Description = "Reduces recoil when firing.",
        Enabled = true,
      },
      ["1764221345"] = {
        HashKey = "COMPONENT_AT_MUZZLE_09",
        Name = "Bell-End Muzzle Brake",
        Description = "Reduces recoil when firing.",
        Enabled = true,
      },
      ["2193687427"] = {
        HashKey = "COMPONENT_AT_SCOPE_LARGE_MK2",
        Name = "Zoom Scope",
        Description = "Long-range zoom functionality.",
        Enabled = true,
      },
      ["2313935527"] = {
        HashKey = "COMPONENT_HEAVYSNIPER_MK2_CLIP_EXPLOSIVE",
        Name = "Explosive Rounds",
        Description = "Bullets which explode on impact. Reduced capacity.",
        AmmoType = "AMMO_SNIPER_EXPLOSIVE",
        Enabled = true,
      },
      ["2425761975"] = {
        HashKey = "COMPONENT_AT_SR_BARREL_01",
        Name = "Default Barrel",
        Description = "Stock barrel attachment.",
        IsDefault = true
      },
      ["2890063729"] = {
        HashKey = "COMPONENT_AT_SR_SUPP_03",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3061846192"] = {
        HashKey = "COMPONENT_AT_SCOPE_NV",
        Name = "Night Vision Scope",
        Description = "Long-range zoom with toggleable night vision.",
        Enabled = true,
      },
      ["3159677559"] = {
        HashKey = "COMPONENT_AT_SCOPE_MAX",
        Name = "Advanced Scope",
        Description = "Maximum zoom functionality.",
        IsDefault = true
      },
      ["4164277972"] = {
        HashKey = "COMPONENT_HEAVYSNIPER_MK2_CLIP_ARMORPIERCING",
        Name = "Armor Piercing Rounds",
        Description = "Increased penetration of Body Armor. Reduced capacity.",
        AmmoType = "AMMO_SNIPER_ARMORPIERCING",
        Enabled = true,
      },
      ["4196276776"] = {
        HashKey = "COMPONENT_HEAVYSNIPER_MK2_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for regular ammo.",
        IsDefault = true
      }
    },
  },
  ["205991906"] = {
    HashKey = "WEAPON_HEAVYSNIPER",
    Name = "Heavy Sniper",
    Description = "Features armor-piercing rounds for heavy damage. Comes with laser scope as standard.",
    Group = "GROUP_SNIPER",
    Enabled = true,
    Components = {
      ["1198478068"] = {
        HashKey = "COMPONENT_HEAVYSNIPER_CLIP_01",
        Name = "Default Clip",
        Description = "",
        IsDefault = true
      },
      ["3159677559"] = {
        HashKey = "COMPONENT_AT_SCOPE_MAX",
        Name = "Advanced Scope",
        Description = "Maximum zoom functionality.",
        IsDefault = true
      },
      ["3527687644"] = {
        HashKey = "COMPONENT_AT_SCOPE_LARGE",
        Name = "Scope",
        Description = "Long-range zoom functionality.",
        IsDefault = true
      }
    },
  },
  ["317205821"] = {
    HashKey = "WEAPON_AUTOSHOTGUN",
    Name = "Sweeper Shotgun",
    Description = "How many effective tools for riot control can you tuck into your pants? OK, two. But this is the other one. Part of Bikers.",
    Group = "GROUP_SHOTGUN",
    Enabled = true,
    Components = {
      ["169463950"] = {
        HashKey = "COMPONENT_AUTOSHOTGUN_CLIP_01",
        Name = "Default Clip",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["324215364"] = {
    HashKey = "WEAPON_MICROSMG",
    Name = "Micro SMG",
    Description = "Combines compact design with a high rate of fire at approximately 700-900 rounds per minute.",
    Group = "GROUP_SMG",
    Enabled = true,
    Components = {
      ["283556395"] = {
        HashKey = "COMPONENT_MICROSMG_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Micro SMG.",
        Enabled = true,
      },
      ["899381934"] = {
        HashKey = "COMPONENT_AT_PI_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2637152041"] = {
        HashKey = "COMPONENT_AT_SCOPE_MACRO",
        Name = "Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["2805810788"] = {
        HashKey = "COMPONENT_AT_AR_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3410538224"] = {
        HashKey = "COMPONENT_MICROSMG_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Micro SMG.",
        IsDefault = true
      }
    },
  },
  ["406929569"] = {
    HashKey = "WEAPON_FERTILIZERCAN",
    Name = "Fertilizer Can",
    Description = "",
    Group = "GROUP_MISC",
    Enabled = true,
    Components = { },
  },
  ["419712736"] = {
    HashKey = "WEAPON_WRENCH",
    Name = "Pipe Wrench",
    Description = "Perennial favourite of apocalyptic survivalists and violent fathers the world over, apparently it also doubles as some kind of tool. Part of Bikers.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["453432689"] = {
    HashKey = "WEAPON_PISTOL",
    Name = "Pistol",
    Description = "Standard handgun. A .45 caliber pistol with a magazine capacity of 12 rounds that can be extended to 16.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["899381934"] = {
        HashKey = "COMPONENT_AT_PI_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["1709866683"] = {
        HashKey = "COMPONENT_AT_PI_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3978713628"] = {
        HashKey = "COMPONENT_PISTOL_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Pistol.",
        Enabled = true,
      },
      ["4275109233"] = {
        HashKey = "COMPONENT_PISTOL_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Pistol.",
        IsDefault = true
      }
    },
  },
  ["487013001"] = {
    HashKey = "WEAPON_PUMPSHOTGUN",
    Name = "Pump Shotgun",
    Description = "Standard shotgun ideal for short-range combat. A high-projectile spread makes up for its lower accuracy at long range.",
    Group = "GROUP_SHOTGUN",
    Enabled = true,
    Components = {
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["3513717816"] = {
        HashKey = "COMPONENT_PUMPSHOTGUN_CLIP_01",
        Name = "",
        Description = "",
        IsDefault = true
      },
      ["3859329886"] = {
        HashKey = "COMPONENT_AT_SR_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
    },
  },
  ["584646201"] = {
    HashKey = "WEAPON_APPISTOL",
    Name = "AP Pistol",
    Description = "High-penetration, fully-automatic pistol. Holds 18 rounds in magazine with option to extend to 36 rounds.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["614078421"] = {
        HashKey = "COMPONENT_APPISTOL_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for AP Pistol.",
        Enabled = true,
      },
      ["834974250"] = {
        HashKey = "COMPONENT_APPISTOL_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for AP Pistol.",
        IsDefault = true
      },
      ["899381934"] = {
        HashKey = "COMPONENT_AT_PI_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["3271853210"] = {
        HashKey = "COMPONENT_AT_PI_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      }
    },
  },
  ["600439132"] = {
    HashKey = "WEAPON_BALL",
    Name = "Ball",
    Description = "",
    Group = "GROUP_THROWN",
    Enabled = true,
    Components = { },
  },
  ["615608432"] = {
    HashKey = "WEAPON_MOLOTOV",
    Name = "Molotov",
    Description = "Crude yet highly effective incendiary weapon. No happy hour with this cocktail.",
    Group = "GROUP_THROWN",
    Enabled = true,
    Components = { },
  },
  ["727643628"] = {
    HashKey = "WEAPON_CERAMICPISTOL",
    Name = "Ceramic Pistol",
    Description = "Not your grandma's ceramics. Although this pint-sized pistol is small enough to fit into her purse and won't set off a metal detector.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["1423184737"] = {
        HashKey = "COMPONENT_CERAMICPISTOL_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for regular ammo.",
        IsDefault = true
      },
      ["2172153001"] = {
        HashKey = "COMPONENT_CERAMICPISTOL_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for regular ammo.",
        Enabled = true,
      },
      ["2466764538"] = {
        HashKey = "COMPONENT_CERAMICPISTOL_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      }
    },
  },
  ["736523883"] = {
    HashKey = "WEAPON_SMG",
    Name = "SMG",
    Description = "This is known as a good all-round submachine gun. Lightweight with an accurate sight and 30-round magazine capacity.",
    Group = "GROUP_SMG",
    Enabled = true,
    Components = {
      ["643254679"] = {
        HashKey = "COMPONENT_SMG_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for SMG.",
        IsDefault = true
      },
      ["889808635"] = {
        HashKey = "COMPONENT_SMG_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for SMG.",
        Enabled = true,
      },
      ["1019656791"] = {
        HashKey = "COMPONENT_AT_SCOPE_MACRO_02",
        Name = "Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["2043113590"] = {
        HashKey = "COMPONENT_SMG_CLIP_03",
        Name = "Drum Magazine",
        Description = "Expanded capacity and slower reload.",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["3271853210"] = {
        HashKey = "COMPONENT_AT_PI_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      }
    },
  },
  ["741814745"] = {
    HashKey = "WEAPON_STICKYBOMB",
    Name = "Sticky Bomb",
    Description = "A plastic explosive charge fitted with a remote detonator. Can be thrown and then detonated or attached to a vehicle then detonated.",
    Group = "GROUP_THROWN",
    Enabled = true,
    Components = { },
  },
  ["883325847"] = {
    HashKey = "WEAPON_PETROLCAN",
    Name = "Jerry Can",
    Description = "Leaves a trail of gasoline that can be ignited.",
    Group = "GROUP_MISC",
    Enabled = true,
    Components = { },
  },
  ["911657153"] = {
    HashKey = "WEAPON_STUNGUN",
    Name = "Stun Gun",
    Description = "Fires a projectile that administers a voltage capable of temporarily stunning an assailant. Takes approximately 4 seconds to recharge after firing.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = { },
  },
  ["940833800"] = {
    HashKey = "WEAPON_STONE_HATCHET",
    Name = "Stone Hatchet",
    Description = "There's retro, there's vintage, and there's this. After 500 years of technological development and spiritual apocalypse, pre-Colombian chic is back.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["961495388"] = {
    HashKey = "WEAPON_ASSAULTRIFLE_MK2",
    Name = "Assault Rifle Mk II",
    Description = "The definitive revision of an all-time classic: all it takes is a little work, and looks can kill after all.",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["48731514"] = {
        HashKey = "COMPONENT_AT_MUZZLE_05",
        Name = "Heavy Duty Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["77277509"] = {
        HashKey = "COMPONENT_AT_SCOPE_MACRO_MK2",
        Name = "Small Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["880736428"] = {
        HashKey = "COMPONENT_AT_MUZZLE_06",
        Name = "Slanted Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["1108334355"] = {
        HashKey = "COMPONENT_AT_SIGHTS",
        Name = "Holographic Sight",
        Description = "Accurate sight for close quarters combat.",
        Enabled = true,
      },
      ["1134861606"] = {
        HashKey = "COMPONENT_AT_AR_BARREL_01",
        Name = "Default Barrel",
        Description = "Stock barrel attachment.",
        IsDefault = true
      },
      ["1303784126"] = {
        HashKey = "COMPONENT_AT_MUZZLE_07",
        Name = "Split-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["1447477866"] = {
        HashKey = "COMPONENT_AT_AR_BARREL_02",
        Name = "Heavy Barrel",
        Description = "Increases damage dealt to long-range targets.",
        Enabled = true,
      },
      ["1675665560"] = {
        HashKey = "COMPONENT_ASSAULTRIFLE_MK2_CLIP_FMJ",
        Name = "Full Metal Jacket Rounds",
        Description = "Increased damage to vehicles. Also penetrates bullet resistant and bulletproof vehicle glass. Reduced capacity.",
        AmmoType = "AMMO_RIFLE_FMJ",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2249208895"] = {
        HashKey = "COMPONENT_ASSAULTRIFLE_MK2_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for regular ammo.",
        IsDefault = true
      },
      ["2640679034"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP_02",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["2805810788"] = {
        HashKey = "COMPONENT_AT_AR_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2816286296"] = {
        HashKey = "COMPONENT_ASSAULTRIFLE_MK2_CLIP_ARMORPIERCING",
        Name = "Armor Piercing Rounds",
        Description = "Increased penetration of Body Armor. Reduced capacity.",
        AmmoType = "AMMO_RIFLE_ARMORPIERCING",
        Enabled = true,
      },
      ["3113485012"] = {
        HashKey = "COMPONENT_AT_MUZZLE_01",
        Name = "Flat Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3328927042"] = {
        HashKey = "COMPONENT_AT_SCOPE_MEDIUM_MK2",
        Name = "Large Scope",
        Description = "Extended-range zoom functionality.",
        Enabled = true,
      },
      ["3362234491"] = {
        HashKey = "COMPONENT_AT_MUZZLE_02",
        Name = "Tactical Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3509242479"] = {
        HashKey = "COMPONENT_ASSAULTRIFLE_MK2_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for regular ammo.",
        Enabled = true,
      },
      ["3725708239"] = {
        HashKey = "COMPONENT_AT_MUZZLE_03",
        Name = "Fat-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3968886988"] = {
        HashKey = "COMPONENT_AT_MUZZLE_04",
        Name = "Precision Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["4012669121"] = {
        HashKey = "COMPONENT_ASSAULTRIFLE_MK2_CLIP_TRACER",
        Name = "Tracer Rounds",
        Description = "Bullets with bright visible markers that match the tint of the gun. Standard capacity.",
        AmmoType = "AMMO_RIFLE_TRACER",
        Enabled = true,
      },
      ["4218476627"] = {
        HashKey = "COMPONENT_ASSAULTRIFLE_MK2_CLIP_INCENDIARY",
        Name = "Incendiary Rounds",
        Description = "Bullets which include a chance to set targets on fire when shot. Reduced capacity.",
        AmmoType = "AMMO_RIFLE_INCENDIARY",
        Enabled = true,
      },
    },
  },
  ["984333226"] = {
    HashKey = "WEAPON_HEAVYSHOTGUN",
    Name = "Heavy Shotgun",
    Description = "The weapon to reach for when you absolutely need to make a horrible mess of the room. Best used near easy-wipe surfaces only. Part of the Last Team Standing Update.",
    Group = "GROUP_SHOTGUN",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["844049759"] = {
        HashKey = "COMPONENT_HEAVYSHOTGUN_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Heavy Shotgun.",
        IsDefault = true
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2294798931"] = {
        HashKey = "COMPONENT_HEAVYSHOTGUN_CLIP_03",
        Name = "Drum Magazine",
        Description = "Expanded capacity and slower reload.",
        Enabled = true,
      },
      ["2535257853"] = {
        HashKey = "COMPONENT_HEAVYSHOTGUN_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Heavy Shotgun.",
        Enabled = true,
      },
      ["2805810788"] = {
        HashKey = "COMPONENT_AT_AR_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      }
    },
  },
  ["1119849093"] = {
    HashKey = "WEAPON_MINIGUN",
    Name = "Minigun",
    Description = "A devastating 6-barrel machine gun that features Gatling-style rotating barrels. Very high rate of fire (2000 to 6000 rounds per minute).",
    Group = "GROUP_HEAVY",
    Enabled = true,
    Components = {
      ["3370020614"] = {
        HashKey = "COMPONENT_MINIGUN_CLIP_01",
        Name = "",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["1141786504"] = {
    HashKey = "WEAPON_GOLFCLUB",
    Name = "Golf Club",
    Description = "Standard length, mid iron golf club with rubber grip for a lethal short game.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["1171102963"] = {
    HashKey = "WEAPON_STUNGUN_MP",
    Name = "Stun Gun",
    Description = "It's, like, literally stunning.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = { },
  },
  ["1198256469"] = {
    HashKey = "WEAPON_RAYCARBINE",
    Name = "Unholy Hellbringer",
    Description = "Republican Space Ranger Special. If you want to turn a little green man into little green goo, this is the only American way to do it.",
    Group = "GROUP_HEAVY",
    Enabled = true,
    Components = { },
  },
  ["1198879012"] = {
    HashKey = "WEAPON_FLAREGUN",
    Name = "Flare Gun",
    Description = "Use to signal distress or drunken excitement. Warning: pointing directly at individuals may cause spontaneous combustion. Part of The Heists Update.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["2481569177"] = {
        HashKey = "COMPONENT_FLAREGUN_CLIP_01",
        Name = "",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["1233104067"] = {
    HashKey = "WEAPON_FLARE",
    Name = "Flare",
    Description = "",
    Group = "GROUP_THROWN",
    Enabled = true,
    Components = { },
  },
  ["1305664598"] = {
    HashKey = "WEAPON_GRENADELAUNCHER_SMOKE",
    Name = "Tear Gas Launcher",
    Description = "",
    Group = "GROUP_HEAVY",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2855028148"] = {
        HashKey = "COMPONENT_AT_SCOPE_SMALL",
        Name = "Scope",
        Description = "Medium-range zoom functionality.",
        Enabled = true,
      }
    },
  },
  ["1317494643"] = {
    HashKey = "WEAPON_HAMMER",
    Name = "Hammer",
    Description = "A robust, multi-purpose hammer with wooden handle and curved claw, this old classic still nails the competition.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["1432025498"] = {
    HashKey = "WEAPON_PUMPSHOTGUN_MK2",
    Name = "Pump Shotgun Mk II",
    Description = "Only one thing pumps more action than a pump action: watch out, the recoil is almost as deadly as the shot.",
    Group = "GROUP_SHOTGUN",
    Enabled = true,
    Components = {
      ["77277509"] = {
        HashKey = "COMPONENT_AT_SCOPE_MACRO_MK2",
        Name = "Small Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["1004815965"] = {
        HashKey = "COMPONENT_PUMPSHOTGUN_MK2_CLIP_EXPLOSIVE",
        Name = "Explosive Slugs",
        Description = "Projectile which explodes on impact.",
        AmmoType = "AMMO_SHOTGUN_EXPLOSIVE",
        Enabled = true,
      },
      ["1060929921"] = {
        HashKey = "COMPONENT_AT_SCOPE_SMALL_MK2",
        Name = "Medium Scope",
        Description = "Medium-range zoom functionality.",
        Enabled = true,
      },
      ["1108334355"] = {
        HashKey = "COMPONENT_AT_SIGHTS",
        Name = "Holographic Sight",
        Description = "Accurate sight for close quarters combat.",
        Enabled = true,
      },
      ["1315288101"] = {
        HashKey = "COMPONENT_PUMPSHOTGUN_MK2_CLIP_ARMORPIERCING",
        Name = "Steel Buckshot Shells",
        Description = "Increased penetration of Body Armor.",
        AmmoType = "AMMO_SHOTGUN_ARMORPIERCING",
        Enabled = true,
      },
      ["1602080333"] = {
        HashKey = "COMPONENT_AT_MUZZLE_08",
        Name = "Squared Muzzle Brake",
        Description = "Reduces recoil when firing.",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2676628469"] = {
        HashKey = "COMPONENT_PUMPSHOTGUN_MK2_CLIP_INCENDIARY",
        Name = "Dragon's Breath Shells",
        Description = "Has a chance to set targets on fire when shot.",
        AmmoType = "AMMO_SHOTGUN_INCENDIARY",
        Enabled = true,
      },
      ["2890063729"] = {
        HashKey = "COMPONENT_AT_SR_SUPP_03",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3449028929"] = {
        HashKey = "COMPONENT_PUMPSHOTGUN_MK2_CLIP_01",
        Name = "Default Shells",
        Description = "Standard shotgun ammunition.",
        IsDefault = true
      },
      ["3914869031"] = {
        HashKey = "COMPONENT_PUMPSHOTGUN_MK2_CLIP_HOLLOWPOINT",
        Name = "Flechette Shells",
        Description = "Increased damage to targets without Body Armor.",
        AmmoType = "AMMO_SHOTGUN_HOLLOWPOINT",
        Enabled = true,
      },
    },
  },
  ["1470379660"] = {
    HashKey = "WEAPON_GADGETPISTOL",
    Name = "Perico Pistol",
    Description = "A deadly shot. Don't be precious. You won't scuff the titanium nitride finish.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["2871488073"] = {
        HashKey = "COMPONENT_GADGETPISTOL_CLIP_01",
        Name = "Default Clip",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["1593441988"] = {
    HashKey = "WEAPON_COMBATPISTOL",
    Name = "Combat Pistol",
    Description = "A compact, lightweight, semi-automatic pistol designed for law enforcement and personal defense. 12-round magazine with option to extend to 16 rounds.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["119648377"] = {
        HashKey = "COMPONENT_COMBATPISTOL_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Combat Pistol.",
        IsDefault = true
      },
      ["899381934"] = {
        HashKey = "COMPONENT_AT_PI_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["3271853210"] = {
        HashKey = "COMPONENT_AT_PI_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3598405421"] = {
        HashKey = "COMPONENT_COMBATPISTOL_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Combat Pistol.",
        Enabled = true,
      }
    },
  },
  ["1627465347"] = {
    HashKey = "WEAPON_GUSENBERG",
    Name = "Gusenberg Sweeper",
    Description = "Complete your look with a Prohibition gun. Looks great being fired from an Albany Roosevelt or paired with a pinstripe suit. Part of the Valentine's Day Massacre Special.",
    Group = "GROUP_MG",
    Enabled = true,
    Components = {
      ["484812453"] = {
        HashKey = "COMPONENT_GUSENBERG_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Gusenberg Sweeper.",
        IsDefault = true
      },
      ["3939025520"] = {
        HashKey = "COMPONENT_GUSENBERG_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Gusenberg Sweeper.",
        Enabled = true,
      }
    },
  },
  ["1649403952"] = {
    HashKey = "WEAPON_COMPACTRIFLE",
    Name = "Compact Rifle",
    Description = "Half the size, all the power, double the recoil: there's no riskier way to say \"I'm compensating for something\". Part of Lowriders: Custom Classics.",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["1363085923"] = {
        HashKey = "COMPONENT_COMPACTRIFLE_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Compact Rifle.",
        IsDefault = true
      },
      ["1509923832"] = {
        HashKey = "COMPONENT_COMPACTRIFLE_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Compact Rifle.",
        Enabled = true,
      },
      ["3322377230"] = {
        HashKey = "COMPONENT_COMPACTRIFLE_CLIP_03",
        Name = "Drum Magazine",
        Description = "Expanded capacity and slower reload.",
        Enabled = true,
      }
    },
  },
  ["1672152130"] = {
    HashKey = "WEAPON_HOMINGLAUNCHER",
    Name = "Homing Launcher",
    Description = "Infrared guided fire-and-forget missile launcher. For all your moving target needs. Part of the Festive Surprise.",
    Group = "GROUP_HEAVY",
    Enabled = true,
    Components = {
      ["4162006335"] = {
        HashKey = "COMPONENT_HOMINGLAUNCHER_CLIP_01",
        Name = "",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["1737195953"] = {
    HashKey = "WEAPON_NIGHTSTICK",
    Name = "Nightstick",
    Description = "24 inch polycarbonate side-handled nightstick.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["1785463520"] = {
    HashKey = "WEAPON_MARKSMANRIFLE_MK2",
    Name = "Marksman Rifle Mk II",
    Description = "Known in military circles as The Dislocator, this mod set will destroy both the target and your shoulder, in that order.",
    Group = "GROUP_SNIPER",
    Enabled = true,
    Components = {
      ["48731514"] = {
        HashKey = "COMPONENT_AT_MUZZLE_05",
        Name = "Heavy Duty Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["880736428"] = {
        HashKey = "COMPONENT_AT_MUZZLE_06",
        Name = "Slanted Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["941317513"] = {
        HashKey = "COMPONENT_AT_MRFL_BARREL_01",
        Name = "Default Barrel",
        Description = "Stock barrel attachment.",
        IsDefault = true
      },
      ["1108334355"] = {
        HashKey = "COMPONENT_AT_SIGHTS",
        Name = "Holographic Sight",
        Description = "Accurate sight for close quarters combat.",
        Enabled = true,
      },
      ["1303784126"] = {
        HashKey = "COMPONENT_AT_MUZZLE_07",
        Name = "Split-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["1528590652"] = {
        HashKey = "COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM_MK2",
        Name = "Zoom Scope",
        Description = "Long-range fixed zoom functionality.",
        IsDefault = true
      },
      ["1748450780"] = {
        HashKey = "COMPONENT_AT_MRFL_BARREL_02",
        Name = "Heavy Barrel",
        Description = "Increases damage dealt to long-range targets.",
        Enabled = true,
      },
      ["1842849902"] = {
        HashKey = "COMPONENT_MARKSMANRIFLE_MK2_CLIP_INCENDIARY",
        Name = "Incendiary Rounds",
        Description = "Bullets which include a chance to set targets on fire when shot. Reduced capacity.",
        AmmoType = "AMMO_SNIPER_INCENDIARY",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2205435306"] = {
        HashKey = "COMPONENT_AT_AR_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2497785294"] = {
        HashKey = "COMPONENT_MARKSMANRIFLE_MK2_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for regular ammo.",
        IsDefault = true
      },
      ["2640679034"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP_02",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["3113485012"] = {
        HashKey = "COMPONENT_AT_MUZZLE_01",
        Name = "Flat Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3328927042"] = {
        HashKey = "COMPONENT_AT_SCOPE_MEDIUM_MK2",
        Name = "Large Scope",
        Description = "Extended-range zoom functionality.",
        Enabled = true,
      },
      ["3362234491"] = {
        HashKey = "COMPONENT_AT_MUZZLE_02",
        Name = "Tactical Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3615105746"] = {
        HashKey = "COMPONENT_MARKSMANRIFLE_MK2_CLIP_TRACER",
        Name = "Tracer Rounds",
        Description = "Bullets with bright visible markers that match the tint of the gun. Standard capacity.",
        AmmoType = "AMMO_SNIPER_TRACER",
        Enabled = true,
      },
      ["3725708239"] = {
        HashKey = "COMPONENT_AT_MUZZLE_03",
        Name = "Fat-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3779763923"] = {
        HashKey = "COMPONENT_MARKSMANRIFLE_MK2_CLIP_FMJ",
        Name = "Full Metal Jacket Rounds",
        Description = "Increased damage to vehicles. Also penetrates bullet resistant and bulletproof vehicle glass. Reduced capacity.",
        AmmoType = "AMMO_SNIPER_FMJ",
        Enabled = true,
      },
      ["3872379306"] = {
        HashKey = "COMPONENT_MARKSMANRIFLE_MK2_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for regular ammo.",
        Enabled = true,
      },
      ["3968886988"] = {
        HashKey = "COMPONENT_AT_MUZZLE_04",
        Name = "Precision Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["4100968569"] = {
        HashKey = "COMPONENT_MARKSMANRIFLE_MK2_CLIP_ARMORPIERCING",
        Name = "Armor Piercing Rounds",
        Description = "Increased penetration of Body Armor. Reduced capacity.",
        AmmoType = "AMMO_SNIPER_ARMORPIERCING",
        Enabled = true,
      },
    },
  },
  ["1834241177"] = {
    HashKey = "WEAPON_RAILGUN",
    Name = "Railgun",
    Description = "All you need to know is - magnets, and it does horrible things to the things it's pointed at. Exclusive content for returning players.",
    Group = "GROUP_HEAVY",
    Enabled = true,
    Components = {
      ["59044840"] = {
        HashKey = "COMPONENT_RAILGUN_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Railgun.",
        IsDefault = true
      }
    },
  },
  ["1853742572"] = {
    HashKey = "WEAPON_PRECISIONRIFLE",
    Name = "Precision Rifle",
    Description = "A rifle for perfectionists. Because why settle for right-between-the-eyes, when you could have right-through-the-superior-frontal-gyrus?",
    Group = "GROUP_SNIPER",
    Enabled = true,
    Components = {
      ["4075474698"] = {
        HashKey = "COMPONENT_PRECISIONRIFLE_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Carbine Rifle.",
        IsDefault = true
      }
    },
  },
  ["2017895192"] = {
    HashKey = "WEAPON_SAWNOFFSHOTGUN",
    Name = "Sawed-Off Shotgun",
    Description = "This single-barrel, sawed-off shotgun compensates for its low range and ammo capacity with devastating efficiency in close combat.",
    Group = "GROUP_SHOTGUN",
    Enabled = true,
    Components = {
      ["3352699429"] = {
        HashKey = "COMPONENT_SAWNOFFSHOTGUN_CLIP_01",
        Name = "",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["2024373456"] = {
    HashKey = "WEAPON_SMG_MK2",
    Name = "SMG Mk II",
    Description = "Lightweight, compact, with a rate of fire to die very messily for: turn any confined space into a kill box at the click of a well-oiled trigger.",
    Group = "GROUP_SMG",
    Enabled = true,
    Components = {
      ["48731514"] = {
        HashKey = "COMPONENT_AT_MUZZLE_05",
        Name = "Heavy Duty Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["190476639"] = {
        HashKey = "COMPONENT_SMG_MK2_CLIP_FMJ",
        Name = "Full Metal Jacket Rounds",
        Description = "Increased damage to vehicles. Also penetrates bullet resistant and bulletproof vehicle glass. Reduced capacity.",
        AmmoType = "AMMO_SMG_FMJ",
        Enabled = true,
      },
      ["880736428"] = {
        HashKey = "COMPONENT_AT_MUZZLE_06",
        Name = "Slanted Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["974903034"] = {
        HashKey = "COMPONENT_SMG_MK2_CLIP_HOLLOWPOINT",
        Name = "Hollow Point Rounds",
        Description = "Increased damage to targets without Body Armor. Reduced capacity.",
        AmmoType = "AMMO_SMG_HOLLOWPOINT",
        Enabled = true,
      },
      ["1038927834"] = {
        HashKey = "COMPONENT_AT_SCOPE_SMALL_SMG_MK2",
        Name = "Medium Scope",
        Description = "Medium-range zoom functionality.",
        Enabled = true,
      },
      ["1277460590"] = {
        HashKey = "COMPONENT_SMG_MK2_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for regular ammo.",
        IsDefault = true
      },
      ["1303784126"] = {
        HashKey = "COMPONENT_AT_MUZZLE_07",
        Name = "Split-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2146055916"] = {
        HashKey = "COMPONENT_SMG_MK2_CLIP_TRACER",
        Name = "Tracer Rounds",
        Description = "Bullets with bright visible markers that match the tint of the gun. Standard capacity.",
        AmmoType = "AMMO_SMG_TRACER",
        Enabled = true,
      },
      ["2681951826"] = {
        HashKey = "COMPONENT_AT_SIGHTS_SMG",
        Name = "Holographic Sight",
        Description = "Accurate sight for close quarters combat.",
        Enabled = true,
      },
      ["2774849419"] = {
        HashKey = "COMPONENT_AT_SB_BARREL_02",
        Name = "Heavy Barrel",
        Description = "Increases damage dealt to long-range targets.",
        Enabled = true,
      },
      ["3112393518"] = {
        HashKey = "COMPONENT_SMG_MK2_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for regular ammo.",
        Enabled = true,
      },
      ["3113485012"] = {
        HashKey = "COMPONENT_AT_MUZZLE_01",
        Name = "Flat Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3271853210"] = {
        HashKey = "COMPONENT_AT_PI_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3362234491"] = {
        HashKey = "COMPONENT_AT_MUZZLE_02",
        Name = "Tactical Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3641720545"] = {
        HashKey = "COMPONENT_AT_SB_BARREL_01",
        Name = "Default Barrel",
        Description = "Stock barrel attachment.",
        IsDefault = true
      },
      ["3650233061"] = {
        HashKey = "COMPONENT_SMG_MK2_CLIP_INCENDIARY",
        Name = "Incendiary Rounds",
        Description = "Bullets which include a chance to set targets on fire when shot. Reduced capacity.",
        AmmoType = "AMMO_SMG_INCENDIARY",
        Enabled = true,
      },
      ["3725708239"] = {
        HashKey = "COMPONENT_AT_MUZZLE_03",
        Name = "Fat-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3842157419"] = {
        HashKey = "COMPONENT_AT_SCOPE_MACRO_02_SMG_MK2",
        Name = "Small Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["3968886988"] = {
        HashKey = "COMPONENT_AT_MUZZLE_04",
        Name = "Precision Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      }
    },
  },
  ["2132975508"] = {
    HashKey = "WEAPON_BULLPUPRIFLE",
    Name = "Bullpup Rifle",
    Description = "The latest Chinese import taking America by storm, this rifle is known for its balanced handling. Lightweight and very controllable in automatic fire. Part of The High Life Update.",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2205435306"] = {
        HashKey = "COMPONENT_AT_AR_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2855028148"] = {
        HashKey = "COMPONENT_AT_SCOPE_SMALL",
        Name = "Scope",
        Description = "Medium-range zoom functionality.",
        Enabled = true,
      },
      ["3009973007"] = {
        HashKey = "COMPONENT_BULLPUPRIFLE_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Bullpup Rifle.",
        Enabled = true,
      },
      ["3315675008"] = {
        HashKey = "COMPONENT_BULLPUPRIFLE_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Bullpup Rifle.",
        IsDefault = true
      }
    },
  },
  ["2138347493"] = {
    HashKey = "WEAPON_FIREWORK",
    Name = "Firework Launcher",
    Description = "Put the flair back in flare with this firework launcher, guaranteed to raise some oohs and aahs from the crowd. Part of the Independence Day Special.",
    Group = "GROUP_HEAVY",
    Enabled = true,
    Components = {
      ["3840197261"] = {
        HashKey = "COMPONENT_FIREWORK_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Firework Launcher.",
        IsDefault = true
      }
    },
  },
  ["2144741730"] = {
    HashKey = "WEAPON_COMBATMG",
    Name = "Combat MG",
    Description = "Lightweight, compact machine gun that combines excellent maneuverability with a high rate of fire to devastating effect.",
    Group = "GROUP_MG",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["2698550338"] = {
        HashKey = "COMPONENT_AT_SCOPE_MEDIUM",
        Name = "Scope",
        Description = "Long-range zoom functionality.",
        Enabled = true,
      },
      ["3603274966"] = {
        HashKey = "COMPONENT_COMBATMG_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Combat MG.",
        Enabled = true,
      },
      ["3791631178"] = {
        HashKey = "COMPONENT_COMBATMG_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Combat MG.",
        IsDefault = true
      }
    },
  },
  ["2210333304"] = {
    HashKey = "WEAPON_CARBINERIFLE",
    Name = "Carbine Rifle",
    Description = "Combining long distance accuracy with a high-capacity magazine, the carbine rifle can be relied on to make the hit.",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["1967214384"] = {
        HashKey = "COMPONENT_AT_RAILCOVER_01",
        Name = "",
        Description = "",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2205435306"] = {
        HashKey = "COMPONENT_AT_AR_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2433783441"] = {
        HashKey = "COMPONENT_CARBINERIFLE_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Carbine Rifle.",
        Enabled = true,
      },
      ["2680042476"] = {
        HashKey = "COMPONENT_CARBINERIFLE_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Carbine Rifle.",
        IsDefault = true
      },
      ["2698550338"] = {
        HashKey = "COMPONENT_AT_SCOPE_MEDIUM",
        Name = "Scope",
        Description = "Long-range zoom functionality.",
        Enabled = true,
      },
      ["3127044405"] = {
        HashKey = "COMPONENT_CARBINERIFLE_CLIP_03",
        Name = "Box Magazine",
        Description = "Expanded capacity and slower reload.",
        Enabled = true,
      },
    },
  },
  ["2227010557"] = {
    HashKey = "WEAPON_CROWBAR",
    Name = "Crowbar",
    Description = "Heavy-duty crowbar forged from high quality, tempered steel for that extra leverage you need to get the job done.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["2228681469"] = {
    HashKey = "WEAPON_BULLPUPRIFLE_MK2",
    Name = "Bullpup Rifle Mk II",
    Description = "So precise, so exquisite, it's not so much a hail of bullets as a symphony.",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["25766362"] = {
        HashKey = "COMPONENT_BULLPUPRIFLE_MK2_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for regular ammo.",
        IsDefault = true
      },
      ["48731514"] = {
        HashKey = "COMPONENT_AT_MUZZLE_05",
        Name = "Heavy Duty Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["880736428"] = {
        HashKey = "COMPONENT_AT_MUZZLE_06",
        Name = "Slanted Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["1005743559"] = {
        HashKey = "COMPONENT_AT_BP_BARREL_02",
        Name = "Heavy Barrel",
        Description = "Increases damage dealt to long-range targets.",
        Enabled = true,
      },
      ["1060929921"] = {
        HashKey = "COMPONENT_AT_SCOPE_SMALL_MK2",
        Name = "Medium Scope",
        Description = "Medium-range zoom functionality.",
        Enabled = true,
      },
      ["1108334355"] = {
        HashKey = "COMPONENT_AT_SIGHTS",
        Name = "Holographic Sight",
        Description = "Accurate sight for close quarters combat.",
        Enabled = true,
      },
      ["1130501904"] = {
        HashKey = "COMPONENT_BULLPUPRIFLE_MK2_CLIP_FMJ",
        Name = "Full Metal Jacket Rounds",
        Description = "Increased damage to vehicles. Also penetrates bullet resistant and bulletproof vehicle glass. Reduced capacity.",
        AmmoType = "AMMO_RIFLE_FMJ",
        Enabled = true,
      },
      ["1303784126"] = {
        HashKey = "COMPONENT_AT_MUZZLE_07",
        Name = "Split-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["1704640795"] = {
        HashKey = "COMPONENT_AT_BP_BARREL_01",
        Name = "Default Barrel",
        Description = "Stock barrel attachment.",
        IsDefault = true
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2183159977"] = {
        HashKey = "COMPONENT_BULLPUPRIFLE_MK2_CLIP_TRACER",
        Name = "Tracer Rounds",
        Description = "Bullets with bright visible markers that match the tint of the gun. Standard capacity.",
        AmmoType = "AMMO_RIFLE_TRACER",
        Enabled = true,
      },
      ["2205435306"] = {
        HashKey = "COMPONENT_AT_AR_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2640679034"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP_02",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["2845636954"] = {
        HashKey = "COMPONENT_BULLPUPRIFLE_MK2_CLIP_INCENDIARY",
        Name = "Incendiary Rounds",
        Description = "Bullets which include a chance to set targets on fire when shot. Reduced capacity.",
        AmmoType = "AMMO_RIFLE_INCENDIARY",
        Enabled = true,
      },
      ["3113485012"] = {
        HashKey = "COMPONENT_AT_MUZZLE_01",
        Name = "Flat Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3350057221"] = {
        HashKey = "COMPONENT_AT_SCOPE_MACRO_02_MK2",
        Name = "Small Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["3362234491"] = {
        HashKey = "COMPONENT_AT_MUZZLE_02",
        Name = "Tactical Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3725708239"] = {
        HashKey = "COMPONENT_AT_MUZZLE_03",
        Name = "Fat-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3968886988"] = {
        HashKey = "COMPONENT_AT_MUZZLE_04",
        Name = "Precision Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["4021290536"] = {
        HashKey = "COMPONENT_BULLPUPRIFLE_MK2_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for regular ammo.",
        Enabled = true,
      },
      ["4205311469"] = {
        HashKey = "COMPONENT_BULLPUPRIFLE_MK2_CLIP_ARMORPIERCING",
        Name = "Armor Piercing Rounds",
        Description = "Increased penetration of Body Armor. Reduced capacity.",
        AmmoType = "AMMO_RIFLE_ARMORPIERCING",
        Enabled = true,
      }
    },
  },
  ["2285322324"] = {
    HashKey = "WEAPON_SNSPISTOL_MK2",
    Name = "SNS Pistol Mk II",
    Description = "The ultimate purse-filler: if you want to make Saturday Night really special, this is your ticket.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["21392614"] = {
        HashKey = "COMPONENT_SNSPISTOL_MK2_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for regular ammo.",
        IsDefault = true
      },
      ["1205768792"] = {
        HashKey = "COMPONENT_AT_PI_RAIL_02",
        Name = "Mounted Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["1246324211"] = {
        HashKey = "COMPONENT_AT_PI_FLSH_03",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["1709866683"] = {
        HashKey = "COMPONENT_AT_PI_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2366665730"] = {
        HashKey = "COMPONENT_SNSPISTOL_MK2_CLIP_HOLLOWPOINT",
        Name = "Hollow Point Rounds",
        Description = "Increased damage to targets without Body Armor.",
        AmmoType = "AMMO_PISTOL_HOLLOWPOINT",
        Enabled = true,
      },
      ["2418909806"] = {
        HashKey = "COMPONENT_SNSPISTOL_MK2_CLIP_TRACER",
        Name = "Tracer Rounds",
        Description = "Bullets with bright visible markers that match the tint of the gun.",
        AmmoType = "AMMO_PISTOL_TRACER",
        Enabled = true,
      },
      ["2860680127"] = {
        HashKey = "COMPONENT_AT_PI_COMP_02",
        Name = "Compensator",
        Description = "Reduces recoil for rapid fire.",
        Enabled = true,
      },
      ["3239176998"] = {
        HashKey = "COMPONENT_SNSPISTOL_MK2_CLIP_FMJ",
        Name = "Full Metal Jacket Rounds",
        Description = "Increased damage to vehicles. Also penetrates bullet resistant and bulletproof vehicle glass.",
        AmmoType = "AMMO_PISTOL_FMJ",
        Enabled = true,
      },
      ["3465283442"] = {
        HashKey = "COMPONENT_SNSPISTOL_MK2_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for regular ammo.",
        Enabled = true,
      },
      ["3870121849"] = {
        HashKey = "COMPONENT_SNSPISTOL_MK2_CLIP_INCENDIARY",
        Name = "Incendiary Rounds",
        Description = "Bullets which include a chance to set targets on fire when shot.",
        AmmoType = "AMMO_PISTOL_INCENDIARY",
        Enabled = true,
      },
    },
  },
  ["2343591895"] = {
    HashKey = "WEAPON_FLASHLIGHT",
    Name = "Flashlight",
    Description = "Intensify your fear of the dark with this short range, battery-powered light source. Handy for blunt force trauma. Part of The Halloween Surprise.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = {
      ["3719772431"] = {
        HashKey = "COMPONENT_FLASHLIGHT_LIGHT",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        IsDefault = true
      }
    },
  },
  ["2441047180"] = {
    HashKey = "WEAPON_NAVYREVOLVER",
    Name = "Navy Revolver",
    Description = "A true museum piece. You want to know how the West was won - slow reload speeds and a whole heap of bloodshed.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["2556346983"] = {
        HashKey = "COMPONENT_NAVYREVOLVER_CLIP_01",
        Name = "Default Clip",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["2460120199"] = {
    HashKey = "WEAPON_DAGGER",
    Name = "Antique Cavalry Dagger",
    Description = "You've been rocking the pirate-chic look for a while, but no vicious weapon to complete the look? Get this dagger with guarded hilt. Part of The \"I'm Not a Hipster\" Update.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["2481070269"] = {
    HashKey = "WEAPON_GRENADE",
    Name = "Grenade",
    Description = "Standard fragmentation grenade. Pull pin, throw, then find cover. Ideal for eliminating clustered assailants.",
    Group = "GROUP_THROWN",
    Enabled = true,
    Components = { },
  },
  ["2484171525"] = {
    HashKey = "WEAPON_POOLCUE",
    Name = "Pool Cue",
    Description = "Ah, there's no sound as satisfying as the crack of a perfect break, especially when it's the other guy's spine. Part of Bikers.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["2508868239"] = {
    HashKey = "WEAPON_BAT",
    Name = "Baseball Bat",
    Description = "Aluminum baseball bat with leather grip. Lightweight yet powerful for all you big hitters out there.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["2526821735"] = {
    HashKey = "WEAPON_SPECIALCARBINE_MK2",
    Name = "Special Carbine Mk II",
    Description = "The jack of all trades just got a serious upgrade: bow to the master.",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["48731514"] = {
        HashKey = "COMPONENT_AT_MUZZLE_05",
        Name = "Heavy Duty Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["77277509"] = {
        HashKey = "COMPONENT_AT_SCOPE_MACRO_MK2",
        Name = "Small Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["382112385"] = {
        HashKey = "COMPONENT_SPECIALCARBINE_MK2_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for regular ammo.",
        IsDefault = true
      },
      ["880736428"] = {
        HashKey = "COMPONENT_AT_MUZZLE_06",
        Name = "Slanted Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["1108334355"] = {
        HashKey = "COMPONENT_AT_SIGHTS",
        Name = "Holographic Sight",
        Description = "Accurate sight for close quarters combat.",
        Enabled = true,
      },
      ["1303784126"] = {
        HashKey = "COMPONENT_AT_MUZZLE_07",
        Name = "Split-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["1346235024"] = {
        HashKey = "COMPONENT_SPECIALCARBINE_MK2_CLIP_FMJ",
        Name = "Full Metal Jacket Rounds",
        Description = "Increased damage to vehicles. Also penetrates bullet resistant and bulletproof vehicle glass. Reduced capacity.",
        AmmoType = "AMMO_RIFLE_FMJ",
        Enabled = true,
      },
      ["1362433589"] = {
        HashKey = "COMPONENT_SPECIALCARBINE_MK2_CLIP_ARMORPIERCING",
        Name = "Armor Piercing Rounds",
        Description = "Increased penetration of Body Armor. Reduced capacity.",
        AmmoType = "AMMO_RIFLE_ARMORPIERCING",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2271594122"] = {
        HashKey = "COMPONENT_SPECIALCARBINE_MK2_CLIP_TRACER",
        Name = "Tracer Rounds",
        Description = "Bullets with bright visible markers that match the tint of the gun. Standard capacity.",
        AmmoType = "AMMO_RIFLE_TRACER",
        Enabled = true,
      },
      ["2640679034"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP_02",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["2805810788"] = {
        HashKey = "COMPONENT_AT_AR_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3113485012"] = {
        HashKey = "COMPONENT_AT_MUZZLE_01",
        Name = "Flat Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3328927042"] = {
        HashKey = "COMPONENT_AT_SCOPE_MEDIUM_MK2",
        Name = "Large Scope",
        Description = "Extended-range zoom functionality.",
        Enabled = true,
      },
      ["3362234491"] = {
        HashKey = "COMPONENT_AT_MUZZLE_02",
        Name = "Tactical Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3724612230"] = {
        HashKey = "COMPONENT_SPECIALCARBINE_MK2_CLIP_INCENDIARY",
        Name = "Incendiary Rounds",
        Description = "Bullets which include a chance to set targets on fire when shot. Reduced capacity.",
        AmmoType = "AMMO_RIFLE_INCENDIARY",
        Enabled = true,
      },
      ["3725708239"] = {
        HashKey = "COMPONENT_AT_MUZZLE_03",
        Name = "Fat-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3726614828"] = {
        HashKey = "COMPONENT_SPECIALCARBINE_MK2_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for regular ammo.",
        Enabled = true,
      },
      ["3879097257"] = {
        HashKey = "COMPONENT_AT_SC_BARREL_01",
        Name = "Default Barrel",
        Description = "Stock barrel attachment.",
        IsDefault = true
      },
      ["3968886988"] = {
        HashKey = "COMPONENT_AT_MUZZLE_04",
        Name = "Precision Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["4185880635"] = {
        HashKey = "COMPONENT_AT_SC_BARREL_02",
        Name = "Heavy Barrel",
        Description = "Increases damage dealt to long-range targets.",
        Enabled = true,
      }
    },
  },
  ["2548703416"] = {
    HashKey = "WEAPON_DOUBLEACTION",
    Name = "Double-Action Revolver",
    Description = "Because sometimes revenge is a dish best served six times, in quick succession, right between the eyes. Part of The Doomsday Heist.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["1328622785"] = {
        HashKey = "COMPONENT_DOUBLEACTION_CLIP_01",
        Name = "Default Clip",
        Description = "Standard ammo capacity.",
        IsDefault = true
      }
    },
  },
  ["2578377531"] = {
    HashKey = "WEAPON_PISTOL50",
    Name = "Pistol .50",
    Description = "High-impact pistol that delivers immense power but with extremely strong recoil. Holds 9 rounds in magazine.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["580369945"] = {
        HashKey = "COMPONENT_PISTOL50_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Pistol .50.",
        IsDefault = true
      },
      ["899381934"] = {
        HashKey = "COMPONENT_AT_PI_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2805810788"] = {
        HashKey = "COMPONENT_AT_AR_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3654528146"] = {
        HashKey = "COMPONENT_PISTOL50_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Pistol .50.",
        Enabled = true,
      }
    },
  },
  ["2578778090"] = {
    HashKey = "WEAPON_KNIFE",
    Name = "Knife",
    Description = "This carbon steel 7 inch bladed knife is dual edged with a serrated spine to provide improved stabbing and thrusting capabilities.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["2634544996"] = {
    HashKey = "WEAPON_MG",
    Name = "MG",
    Description = "General purpose machine gun that combines rugged design with dependable performance. Long range penetrative power. Very effective against large groups.",
    Group = "GROUP_MG",
    Enabled = true,
    Components = {
      ["1006677997"] = {
        HashKey = "COMPONENT_AT_SCOPE_SMALL_02",
        Name = "Scope",
        Description = "Medium-range zoom functionality.",
        Enabled = true,
      },
      ["2182449991"] = {
        HashKey = "COMPONENT_MG_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for MG.",
        Enabled = true,
      },
      ["4097109892"] = {
        HashKey = "COMPONENT_MG_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for MG.",
        IsDefault = true
      }
    },
  },
  ["2636060646"] = {
    HashKey = "WEAPON_MILITARYRIFLE",
    Name = "Military Rifle",
    Description = "This immensely powerful assault rifle was designed for highly qualified, exceptionally skilled soldiers. Yes, you can buy it.",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["759617595"] = {
        HashKey = "COMPONENT_MILITARYRIFLE_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for regular ammo.",
        IsDefault = true
      },
      ["1749732930"] = {
        HashKey = "COMPONENT_MILITARYRIFLE_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for regular ammo.",
        Enabled = true,
      },
      ["1803744149"] = {
        HashKey = "COMPONENT_MILITARYRIFLE_SIGHT_01",
        Name = "Iron Sights",
        Description = "Default rail-mounted iron sights.",
        IsDefault = true
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2205435306"] = {
        HashKey = "COMPONENT_AT_AR_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2855028148"] = {
        HashKey = "COMPONENT_AT_SCOPE_SMALL",
        Name = "Scope",
        Description = "Medium-range zoom functionality.",
        Enabled = true,
      }
    },
  },
  ["2640438543"] = {
    HashKey = "WEAPON_BULLPUPSHOTGUN",
    Name = "Bullpup Shotgun",
    Description = "More than makes up for its slow, pump-action rate of fire with its range and spread.  Decimates anything in its projectile path.",
    Group = "GROUP_SHOTGUN",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["3377353998"] = {
        HashKey = "COMPONENT_BULLPUPSHOTGUN_CLIP_01",
        Name = "",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["2694266206"] = {
    HashKey = "WEAPON_BZGAS",
    Name = "BZ Gas",
    Description = "",
    Group = "GROUP_THROWN",
    Enabled = true,
    Components = { },
  },
  ["2726580491"] = {
    HashKey = "WEAPON_GRENADELAUNCHER",
    Name = "Grenade Launcher",
    Description = "A compact, lightweight grenade launcher with semi-automatic functionality. Holds up to 10 rounds.",
    Group = "GROUP_HEAVY",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["296639639"] = {
        HashKey = "COMPONENT_GRENADELAUNCHER_CLIP_01",
        Name = "",
        Description = "",
        IsDefault = true
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2855028148"] = {
        HashKey = "COMPONENT_AT_SCOPE_SMALL",
        Name = "Scope",
        Description = "Medium-range zoom functionality.",
        Enabled = true,
      }
    },
  },
  ["2828843422"] = {
    HashKey = "WEAPON_MUSKET",
    Name = "Musket",
    Description = "Armed with nothing but muskets and a superiority complex, the Brits took over half the world. Own the gun that built an empire. Part of the Independence Day Special.",
    Group = "GROUP_SNIPER",
    Enabled = true,
    Components = {
      ["1322387263"] = {
        HashKey = "COMPONENT_MUSKET_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Musket.",
        IsDefault = true
      }
    },
  },
  ["2874559379"] = {
    HashKey = "WEAPON_PROXMINE",
    Name = "Proximity Mine",
    Description = "Leave a present for your friends with these motion sensor landmines. Short delay after activation. Part of the Festive Surprise.",
    Group = "GROUP_THROWN",
    Enabled = true,
    Components = { },
  },
  ["2937143193"] = {
    HashKey = "WEAPON_ADVANCEDRIFLE",
    Name = "Advanced Rifle",
    Description = "The most lightweight and compact of all assault rifles, without compromising accuracy and rate of fire.",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2205435306"] = {
        HashKey = "COMPONENT_AT_AR_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2395064697"] = {
        HashKey = "COMPONENT_ADVANCEDRIFLE_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Assault Rifle.",
        Enabled = true,
      },
      ["2855028148"] = {
        HashKey = "COMPONENT_AT_SCOPE_SMALL",
        Name = "Scope",
        Description = "Medium-range zoom functionality.",
        Enabled = true,
      },
      ["4203716879"] = {
        HashKey = "COMPONENT_ADVANCEDRIFLE_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Assault Rifle.",
        IsDefault = true
      }
    },
  },
  ["2939590305"] = {
    HashKey = "WEAPON_RAYPISTOL",
    Name = "Up-n-Atomizer",
    Description = "Republican Space Ranger Special, fresh from the galactic war on socialism: no ammo, no mag, just one brutal energy pulse after another.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {},
  },
  ["2982836145"] = {
    HashKey = "WEAPON_RPG",
    Name = "RPG",
    Description = "A portable, shoulder-launched, anti-tank weapon that fires explosive warheads. Very effective for taking down vehicles or large groups of assailants.",
    Group = "GROUP_HEAVY",
    Enabled = true,
    Components = {
      ["1319465907"] = {
        HashKey = "COMPONENT_RPG_CLIP_01",
        Name = "",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["3056410471"] = {
    HashKey = "WEAPON_RAYMINIGUN",
    Name = "Widowmaker",
    Description = "Republican Space Ranger Special. GO AHEAD, SAY I'M COMPENSATING FOR SOMETHING. I DARE YOU.",
    Group = "GROUP_HEAVY",
    Enabled = true,
    Components = {
      ["3370020614"] = {
        HashKey = "COMPONENT_MINIGUN_CLIP_01",
        Name = "",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["3125143736"] = {
    HashKey = "WEAPON_PIPEBOMB",
    Name = "Pipe Bomb",
    Description = "Remember, it doesn't count as an IED when you buy it in a store and use it in a first world country. Part of Bikers.",
    Group = "GROUP_THROWN",
    Enabled = true,
    Components = { },
  },
  ["3126027122"] = {
    HashKey = "WEAPON_HAZARDCAN",
    Name = "Hazardous Jerry Can",
    Description = "",
    Group = "GROUP_MISC",
    Enabled = true,
    Components = { },
  },
  ["3173288789"] = {
    HashKey = "WEAPON_MINISMG",
    Name = "Mini SMG",
    Description = "Increasingly popular since the marketing team looked beyond spec ops units and started caring about the little guys in low income areas. Part of Bikers.",
    Group = "GROUP_SMG",
    Enabled = true,
    Components = {
      ["2227745491"] = {
        HashKey = "COMPONENT_MINISMG_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Mini SMG.",
        IsDefault = true
      },
      ["2474561719"] = {
        HashKey = "COMPONENT_MINISMG_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Mini SMG.",
        Enabled = true,
      }
    },
  },
  ["3218215474"] = {
    HashKey = "WEAPON_SNSPISTOL",
    Name = "SNS Pistol",
    Description = "Like condoms or hairspray, this fits in your pocket for a night out in a Vinewood club. It's half as accurate as a champagne cork but twice as deadly. Part of the Beach Bum Pack.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["2063610803"] = {
        HashKey = "COMPONENT_SNSPISTOL_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for SNS Pistol.",
        Enabled = true,
      },
      ["4169150169"] = {
        HashKey = "COMPONENT_SNSPISTOL_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for SNS Pistol.",
        IsDefault = true
      }
    },
  },
  ["3219281620"] = {
    HashKey = "WEAPON_PISTOL_MK2",
    Name = "Pistol Mk II",
    Description = "Balance, simplicity, precision: nothing keeps the peace like an extended barrel in the other guy's mouth.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["568543123"] = {
        HashKey = "COMPONENT_AT_PI_COMP",
        Name = "Compensator",
        Description = "Reduces recoil for rapid fire.",
        Enabled = true,
      },
      ["634039983"] = {
        HashKey = "COMPONENT_PISTOL_MK2_CLIP_TRACER",
        Name = "Tracer Rounds",
        Description = "Bullets with bright visible markers that match the tint of the gun. Standard capacity.",
        AmmoType = "AMMO_PISTOL_TRACER",
        Enabled = true,
      },
      ["733837882"] = {
        HashKey = "COMPONENT_PISTOL_MK2_CLIP_INCENDIARY",
        Name = "Incendiary Rounds",
        Description = "Bullets which include a chance to set targets on fire when shot. Reduced capacity.",
        AmmoType = "AMMO_PISTOL_INCENDIARY",
        Enabled = true,
      },
      ["1140676955"] = {
        HashKey = "COMPONENT_AT_PI_FLSH_02",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["1329061674"] = {
        HashKey = "COMPONENT_PISTOL_MK2_CLIP_FMJ",
        Name = "Full Metal Jacket Rounds",
        Description = "Increased damage to vehicles. Also penetrates bullet resistant and bulletproof vehicle glass. Reduced capacity.",
        AmmoType = "AMMO_PISTOL_FMJ",
        Enabled = true,
      },
      ["1591132456"] = {
        HashKey = "COMPONENT_PISTOL_MK2_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for regular ammo.",
        Enabled = true,
      },
      ["1709866683"] = {
        HashKey = "COMPONENT_AT_PI_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2248057097"] = {
        HashKey = "COMPONENT_PISTOL_MK2_CLIP_HOLLOWPOINT",
        Name = "Hollow Point Rounds",
        Description = "Increased damage to targets without Body Armor. Reduced capacity.",
        AmmoType = "AMMO_PISTOL_HOLLOWPOINT",
        Enabled = true,
      },
      ["2396306288"] = {
        HashKey = "COMPONENT_AT_PI_RAIL",
        Name = "Mounted Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["2499030370"] = {
        HashKey = "COMPONENT_PISTOL_MK2_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for regular ammo.",
        IsDefault = true
      },
    },
  },
  ["3220176749"] = {
    HashKey = "WEAPON_ASSAULTRIFLE",
    Name = "Assault Rifle",
    Description = "This standard assault rifle boasts a large capacity magazine and long distance accuracy.",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2637152041"] = {
        HashKey = "COMPONENT_AT_SCOPE_MACRO",
        Name = "Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["2805810788"] = {
        HashKey = "COMPONENT_AT_AR_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2971750299"] = {
        HashKey = "COMPONENT_ASSAULTRIFLE_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Assault Rifle.",
        Enabled = true,
      },
      ["3193891350"] = {
        HashKey = "COMPONENT_ASSAULTRIFLE_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Assault Rifle.",
        IsDefault = true
      },
      ["3689981245"] = {
        HashKey = "COMPONENT_ASSAULTRIFLE_CLIP_03",
        Name = "Drum Magazine",
        Description = "Expanded capacity and slower reload.",
        Enabled = true,
      }
    },
  },
  ["3231910285"] = {
    HashKey = "WEAPON_SPECIALCARBINE",
    Name = "Special Carbine",
    Description = "Combining accuracy, maneuverability and low recoil, this is an extremely versatile assault rifle for any combat situation. Part of The Business Update.",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["1801039530"] = {
        HashKey = "COMPONENT_SPECIALCARBINE_CLIP_03",
        Name = "Drum Magazine",
        Description = "Expanded capacity and slower reload.",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2089537806"] = {
        HashKey = "COMPONENT_SPECIALCARBINE_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Special Carbine.",
        Enabled = true,
      },
      ["2698550338"] = {
        HashKey = "COMPONENT_AT_SCOPE_MEDIUM",
        Name = "Scope",
        Description = "Long-range zoom functionality.",
        Enabled = true,
      },
      ["2805810788"] = {
        HashKey = "COMPONENT_AT_AR_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3334989185"] = {
        HashKey = "COMPONENT_SPECIALCARBINE_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Special Carbine.",
        IsDefault = true
      }
    },
  },
  ["3249783761"] = {
    HashKey = "WEAPON_REVOLVER",
    Name = "Heavy Revolver",
    Description = "A handgun with enough stopping power to drop a crazed rhino, and heavy enough to beat it to death if you're out of ammo. Part of Executives and Other Criminals.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["3917905123"] = {
        HashKey = "COMPONENT_REVOLVER_CLIP_01",
        Name = "Default Clip",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["3342088282"] = {
    HashKey = "WEAPON_MARKSMANRIFLE",
    Name = "Marksman Rifle",
    Description = "Whether you're up close or a disconcertingly long way away, this weapon will get the job done. A multi-range tool for tools. Part of the Last Team Standing Update.",
    Group = "GROUP_SNIPER",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["471997210"] = {
        HashKey = "COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM",
        Name = "Scope",
        Description = "Long-range fixed zoom functionality.",
        IsDefault = true
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2205435306"] = {
        HashKey = "COMPONENT_AT_AR_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3439143621"] = {
        HashKey = "COMPONENT_MARKSMANRIFLE_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Marksman Rifle.",
        Enabled = true,
      },
      ["3627761985"] = {
        HashKey = "COMPONENT_MARKSMANRIFLE_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Marksman Rifle.",
        IsDefault = true
      }
    },
  },
  ["3347935668"] = {
    HashKey = "WEAPON_HEAVYRIFLE",
    Name = "Heavy Rifle",
    Description = "The no-holds-barred 30-round answer to that eternal question, how do I get this guy off my back?",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["1525977990"] = {
        HashKey = "COMPONENT_HEAVYRIFLE_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Heavy Rifle.",
        IsDefault = true
      },
      ["1824470811"] = {
        HashKey = "COMPONENT_HEAVYRIFLE_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Heavy Rifle.",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2205435306"] = {
        HashKey = "COMPONENT_AT_AR_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2698550338"] = {
        HashKey = "COMPONENT_AT_SCOPE_MEDIUM",
        Name = "Scope",
        Description = "Long-range zoom functionality.",
        Enabled = true,
      },
      ["3017917522"] = {
        HashKey = "COMPONENT_HEAVYRIFLE_SIGHT_01",
        Name = "Iron Sights",
        Description = "Default rail-mounted iron sights.",
        IsDefault = true
      },
    },
  },
  ["3415619887"] = {
    HashKey = "WEAPON_REVOLVER_MK2",
    Name = "Heavy Revolver Mk II",
    Description = "If you can lift it, this is the closest you'll get to shooting someone with a freight train.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["15712037"] = {
        HashKey = "COMPONENT_REVOLVER_MK2_CLIP_INCENDIARY",
        Name = "Incendiary Rounds",
        Description = "Bullets which set targets on fire when shot.",
        AmmoType = "AMMO_PISTOL_INCENDIARY",
        Enabled = true,
      },
      ["77277509"] = {
        HashKey = "COMPONENT_AT_SCOPE_MACRO_MK2",
        Name = "Small Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["231258687"] = {
        HashKey = "COMPONENT_REVOLVER_MK2_CLIP_FMJ",
        Name = "Full Metal Jacket Rounds",
        Description = "Increased damage to vehicles. Also penetrates bullet resistant and bulletproof vehicle glass.",
        AmmoType = "AMMO_PISTOL_FMJ",
        Enabled = true,
      },
      ["284438159"] = {
        HashKey = "COMPONENT_REVOLVER_MK2_CLIP_HOLLOWPOINT",
        Name = "Hollow Point Rounds",
        Description = "Increased damage to targets without Body Armor.",
        AmmoType = "AMMO_PISTOL_HOLLOWPOINT",
        Enabled = true,
      },
      ["654802123"] = {
        HashKey = "COMPONENT_AT_PI_COMP_03",
        Name = "Compensator",
        Description = "Reduces recoil for rapid fire.",
        Enabled = true,
      },
      ["899381934"] = {
        HashKey = "COMPONENT_AT_PI_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["1108334355"] = {
        HashKey = "COMPONENT_AT_SIGHTS",
        Name = "Holographic Sight",
        Description = "Accurate sight for close quarters combat.",
        Enabled = true,
      },
      ["3122911422"] = {
        HashKey = "COMPONENT_REVOLVER_MK2_CLIP_01",
        Name = "Default Rounds",
        Description = "Standard revolver ammunition.",
        IsDefault = true
      },
      ["3336103030"] = {
        HashKey = "COMPONENT_REVOLVER_MK2_CLIP_TRACER",
        Name = "Tracer Rounds",
        Description = "Bullets with bright visible markers that match the tint of the gun.",
        AmmoType = "AMMO_PISTOL_TRACER",
        Enabled = true,
      },
    },
  },
  ["3441901897"] = {
    HashKey = "WEAPON_BATTLEAXE",
    Name = "Battle Axe",
    Description = "If it's good enough for medieval foot soldiers, modern border guards and pushy soccer moms, it's good enough for you. Part of Bikers.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["3520460075"] = {
    HashKey = "WEAPON_TACTICALRIFLE",
    Name = "Service Carbine",
    Description = "This season's must-have hardware for law enforcement, military personnel and anyone locked in a fight to the death with either law enforcement or military personnel.",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["927578299"] = {
        HashKey = "COMPONENT_TACTICALRIFLE_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Carbine Rifle.",
        IsDefault = true
      },
      ["2241090895"] = {
        HashKey = "COMPONENT_TACTICALRIFLE_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Carbine Rifle.",
        Enabled = true,
      },
      ["2645680163"] = {
        HashKey = "COMPONENT_AT_AR_FLSH_REH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2805810788"] = {
        HashKey = "COMPONENT_AT_AR_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      }
    },
  },
  ["3523564046"] = {
    HashKey = "WEAPON_HEAVYPISTOL",
    Name = "Heavy Pistol",
    Description = "The heavyweight champion of the magazine fed, semi-automatic handgun world. Delivers a serious forearm workout every time. Part of The Business Update.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["222992026"] = {
        HashKey = "COMPONENT_HEAVYPISTOL_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Heavy Pistol.",
        IsDefault = true
      },
      ["899381934"] = {
        HashKey = "COMPONENT_AT_PI_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["1694090795"] = {
        HashKey = "COMPONENT_HEAVYPISTOL_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Heavy Pistol.",
        Enabled = true,
      },
      ["3271853210"] = {
        HashKey = "COMPONENT_AT_PI_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      }
    },
  },
  ["3638508604"] = {
    HashKey = "WEAPON_KNUCKLE",
    Name = "Knuckle Duster",
    Description = "Perfect for knocking out gold teeth, or as a gift to the trophy partner who has everything. Part of The Ill-Gotten Gains Update Part 2.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = {
      ["146278587"] = {
        HashKey = "COMPONENT_KNUCKLE_VARMOD_PLAYER",
        Name = "The Player",
        Description = "",
        Enabled = true,
      },
      ["1062111910"] = {
        HashKey = "COMPONENT_KNUCKLE_VARMOD_LOVE",
        Name = "The Lover",
        Description = "",
        Enabled = true,
      },
      ["1351683121"] = {
        HashKey = "COMPONENT_KNUCKLE_VARMOD_DOLLAR",
        Name = "The Hustler",
        Description = "",
        Enabled = true,
      },
      ["2062808965"] = {
        HashKey = "COMPONENT_KNUCKLE_VARMOD_VAGOS",
        Name = "The Vagos",
        Description = "",
        Enabled = true,
      },
      ["2112683568"] = {
        HashKey = "COMPONENT_KNUCKLE_VARMOD_HATE",
        Name = "The Hater",
        Description = "",
        Enabled = true,
      },
      ["2539772380"] = {
        HashKey = "COMPONENT_KNUCKLE_VARMOD_DIAMOND",
        Name = "The Rock",
        Description = "",
        Enabled = true,
      },
      ["3323197061"] = {
        HashKey = "COMPONENT_KNUCKLE_VARMOD_PIMP",
        Name = "The Pimp",
        Description = "",
        Enabled = true,
      },
      ["3800804335"] = {
        HashKey = "COMPONENT_KNUCKLE_VARMOD_KING",
        Name = "The King",
        Description = "",
        Enabled = true,
      },
      ["4007263587"] = {
        HashKey = "COMPONENT_KNUCKLE_VARMOD_BALLAS",
        Name = "The Ballas",
        Description = "",
        Enabled = true,
      },
      ["4081463091"] = {
        HashKey = "COMPONENT_KNUCKLE_VARMOD_BASE",
        Name = "Base Model",
        Enabled = true,
      }
    },
  },
  ["3675956304"] = {
    HashKey = "WEAPON_MACHINEPISTOL",
    Name = "Machine Pistol",
    Description = "This fully automatic is the snare drum to your twin-engine V8 bass: no drive-by sounds quite right without it. Part of Lowriders.",
    Group = "GROUP_SMG",
    Enabled = true,
    Components = {
      ["1198425599"] = {
        HashKey = "COMPONENT_MACHINEPISTOL_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Machine Pistol.",
        IsDefault = true
      },
      ["2850671348"] = {
        HashKey = "COMPONENT_MACHINEPISTOL_CLIP_03",
        Name = "Drum Magazine",
        Enabled = true,
      },
      ["3106695545"] = {
        HashKey = "COMPONENT_MACHINEPISTOL_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Machine Pistol.",
        Enabled = true,
      },
      ["3271853210"] = {
        HashKey = "COMPONENT_AT_PI_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      }
    },
  },
  ["3676729658"] = {
    HashKey = "WEAPON_EMPLAUNCHER",
    Name = "Compact EMP Launcher",
    Description = "Ever seen a confetti cannon? The Compact EMP Launcher is just like that, but instead of paper and happiness, it's an electromagnetic pulse, short circuits and shattered dreams.",
    Group = "GROUP_HEAVY",
    Enabled = true,
    Components = {
      ["3532609777"] = {
        HashKey = "COMPONENT_EMPLAUNCHER_CLIP_01",
        Name = "Default Clip",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["3684886537"] = {
    HashKey = "WEAPON_METALDETECTOR",
    Name = "Metal Detector",
    Description = "** PLACEHOLDER METAL DETECTOR DESCRIPTION **",
    Group = "GROUP_MISC",
    Enabled = true,
    Components = { },
  },
  ["3686625920"] = {
    HashKey = "WEAPON_COMBATMG_MK2",
    Name = "Combat MG Mk II",
    Description = "You can never have too much of a good thing: after all, if the first shot counts, then the next hundred or so must count for double.",
    Group = "GROUP_MG",
    Enabled = true,
    Components = {
      ["48731514"] = {
        HashKey = "COMPONENT_AT_MUZZLE_05",
        Name = "Heavy Duty Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["400507625"] = {
        HashKey = "COMPONENT_COMBATMG_MK2_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for regular ammo.",
        Enabled = true,
      },
      ["696788003"] = {
        HashKey = "COMPONENT_COMBATMG_MK2_CLIP_ARMORPIERCING",
        Name = "Armor Piercing Rounds",
        Description = "Increased penetration of Body Armor. Reduced capacity.",
        AmmoType = "AMMO_MG_ARMORPIERCING",
        Enabled = true,
      },
      ["880736428"] = {
        HashKey = "COMPONENT_AT_MUZZLE_06",
        Name = "Slanted Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["1060929921"] = {
        HashKey = "COMPONENT_AT_SCOPE_SMALL_MK2",
        Name = "Medium Scope",
        Description = "Medium-range zoom functionality.",
        Enabled = true,
      },
      ["1108334355"] = {
        HashKey = "COMPONENT_AT_SIGHTS",
        Name = "Holographic Sight",
        Description = "Accurate sight for close quarters combat.",
        Enabled = true,
      },
      ["1227564412"] = {
        HashKey = "COMPONENT_COMBATMG_MK2_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for regular ammo.",
        IsDefault = true
      },
      ["1303784126"] = {
        HashKey = "COMPONENT_AT_MUZZLE_07",
        Name = "Split-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["1475288264"] = {
        HashKey = "COMPONENT_COMBATMG_MK2_CLIP_FMJ",
        Name = "Full Metal Jacket Rounds",
        Description = "Increased damage to vehicles. Also penetrates bullet resistant and bulletproof vehicle glass. Reduced capacity.",
        AmmoType = "AMMO_MG_FMJ",
        Enabled = true,
      },
      ["2640679034"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP_02",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["3051509595"] = {
        HashKey = "COMPONENT_AT_MG_BARREL_02",
        Name = "Heavy Barrel",
        Description = "Increases damage dealt to long-range targets.",
        Enabled = true,
      },
      ["3113485012"] = {
        HashKey = "COMPONENT_AT_MUZZLE_01",
        Name = "Flat Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3274096058"] = {
        HashKey = "COMPONENT_COMBATMG_MK2_CLIP_INCENDIARY",
        Name = "Incendiary Rounds",
        Description = "Bullets which include a chance to set targets on fire when shot. Reduced capacity.",
        AmmoType = "AMMO_MG_INCENDIARY",
        Enabled = true,
      },
      ["3276730932"] = {
        HashKey = "COMPONENT_AT_MG_BARREL_01",
        Name = "Default Barrel",
        Description = "Stock barrel attachment.",
        IsDefault = true
      },
      ["3328927042"] = {
        HashKey = "COMPONENT_AT_SCOPE_MEDIUM_MK2",
        Name = "Large Scope",
        Description = "Extended-range zoom functionality.",
        Enabled = true,
      },
      ["3362234491"] = {
        HashKey = "COMPONENT_AT_MUZZLE_02",
        Name = "Tactical Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3725708239"] = {
        HashKey = "COMPONENT_AT_MUZZLE_03",
        Name = "Fat-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3968886988"] = {
        HashKey = "COMPONENT_AT_MUZZLE_04",
        Name = "Precision Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["4133787461"] = {
        HashKey = "COMPONENT_COMBATMG_MK2_CLIP_TRACER",
        Name = "Tracer Rounds",
        Description = "Bullets with bright visible markers that match the tint of the gun. Standard capacity.",
        AmmoType = "AMMO_MG_TRACER",
        Enabled = true,
      }
    },
  },
  ["3696079510"] = {
    HashKey = "WEAPON_MARKSMANPISTOL",
    Name = "Marksman Pistol",
    Description = "Not for the risk averse. Make it count as you'll be reloading as much as you shoot. Part of The Ill-Gotten Gains Update Part 2.",
    Group = "GROUP_PISTOL",
    Enabled = true,
    Components = {
      ["3416146413"] = {
        HashKey = "COMPONENT_MARKSMANPISTOL_CLIP_01",
        Name = "Default Clip",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["3713923289"] = {
    HashKey = "WEAPON_MACHETE",
    Name = "Machete",
    Description = "America's West African arms trade isn't just about giving. Rediscover the simple life with this rusty cleaver. Part of Lowriders.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["3756226112"] = {
    HashKey = "WEAPON_SWITCHBLADE",
    Name = "Switchblade",
    Description = "From your pocket to hilt-deep in the other guy's ribs in under a second: folding knives will never go out of style. Part of Executives and Other Criminals.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = {
      ["1530822070"] = {
        HashKey = "COMPONENT_SWITCHBLADE_VARMOD_VAR1",
        Name = "VIP Variant",
        Description = "",
        Enabled = true,
      },
      ["2436343040"] = {
        HashKey = "COMPONENT_SWITCHBLADE_VARMOD_BASE",
        Name = "Default Handle",
        Description = "",
        Enabled = true,
      },
      ["3885209186"] = {
        HashKey = "COMPONENT_SWITCHBLADE_VARMOD_VAR2",
        Name = "Bodyguard Variant",
        Description = "",
        Enabled = true,
      }
    },
  },
  ["3800352039"] = {
    HashKey = "WEAPON_ASSAULTSHOTGUN",
    Name = "Assault Shotgun",
    Description = "Fully automatic shotgun with 8 round magazine and high rate of fire.",
    Group = "GROUP_SHOTGUN",
    Enabled = true,
    Components = {
      ["202788691"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2205435306"] = {
        HashKey = "COMPONENT_AT_AR_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2260565874"] = {
        HashKey = "COMPONENT_ASSAULTSHOTGUN_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for Assault Shotgun.",
        Enabled = true,
      },
      ["2498239431"] = {
        HashKey = "COMPONENT_ASSAULTSHOTGUN_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for Assault Shotgun.",
        IsDefault = true
      }
    },
  },
  ["4019527611"] = {
    HashKey = "WEAPON_DBSHOTGUN",
    Name = "Double Barrel Shotgun",
    Description = "Do one thing, do it well. Who needs a high rate of fire when your first shot turns the other guy into a fine mist? Part of Lowriders: Custom Classics.",
    Group = "GROUP_SHOTGUN",
    Enabled = true,
    Components = {
      ["703231006"] = {
        HashKey = "COMPONENT_DBSHOTGUN_CLIP_01",
        Name = "",
        Description = "",
        IsDefault = true
      }
    },
  },
  ["4024951519"] = {
    HashKey = "WEAPON_ASSAULTSMG",
    Name = "Assault SMG",
    Description = "A high-capacity submachine gun that is both compact and lightweight. Holds up to 30 bullets in one magazine.",
    Group = "GROUP_SMG",
    Enabled = true,
    Components = {
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2366834608"] = {
        HashKey = "COMPONENT_ASSAULTSMG_CLIP_01",
        Name = "Default Clip",
        Description = "",
        IsDefault = true
      },
      ["2637152041"] = {
        HashKey = "COMPONENT_AT_SCOPE_MACRO",
        Name = "Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["2805810788"] = {
        HashKey = "COMPONENT_AT_AR_SUPP_02",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["3141985303"] = {
        HashKey = "COMPONENT_ASSAULTSMG_CLIP_02",
        Name = "Extended Clip",
        Description = "",
        Enabled = true,
      }
    },
  },
  ["4191993645"] = {
    HashKey = "WEAPON_HATCHET",
    Name = "Hatchet",
    Description = "Make kindling... of your pals with this easy to wield, easy to hide hatchet. Exclusive content for returning players.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["4192643659"] = {
    HashKey = "WEAPON_BOTTLE",
    Name = "Bottle",
    Description = "It's not clever and it's not pretty but, most of the time, neither is the guy coming at you with a knife. When all else fails, this gets the job done. Part of the Beach Bum Pack.",
    Group = "GROUP_MELEE",
    Enabled = true,
    Components = { },
  },
  ["4208062921"] = {
    HashKey = "WEAPON_CARBINERIFLE_MK2",
    Name = "Carbine Rifle Mk II",
    Description = "This is bespoke, artisan firepower: you couldn't deliver a hail of bullets with more love and care if you inserted them by hand.",
    Group = "GROUP_RIFLE",
    Enabled = true,
    Components = {
      ["48731514"] = {
        HashKey = "COMPONENT_AT_MUZZLE_05",
        Name = "Heavy Duty Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["77277509"] = {
        HashKey = "COMPONENT_AT_SCOPE_MACRO_MK2",
        Name = "Small Scope",
        Description = "Standard-range zoom functionality.",
        Enabled = true,
      },
      ["391640422"] = {
        HashKey = "COMPONENT_CARBINERIFLE_MK2_CLIP_TRACER",
        Name = "Tracer Rounds",
        Description = "Bullets with bright visible markers that match the tint of the gun. Standard capacity.",
        AmmoType = "AMMO_RIFLE_TRACER",
        Enabled = true,
      },
      ["626875735"] = {
        HashKey = "COMPONENT_CARBINERIFLE_MK2_CLIP_ARMORPIERCING",
        Name = "Armor Piercing Rounds",
        Description = "Increased penetration of Body Armor. Reduced capacity.",
        AmmoType = "AMMO_RIFLE_ARMORPIERCING",
        Enabled = true,
      },
      ["880736428"] = {
        HashKey = "COMPONENT_AT_MUZZLE_06",
        Name = "Slanted Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["1025884839"] = {
        HashKey = "COMPONENT_CARBINERIFLE_MK2_CLIP_INCENDIARY",
        Name = "Incendiary Rounds",
        Description = "Bullets which include a chance to set targets on fire when shot. Reduced capacity.",
        AmmoType = "AMMO_RIFLE_INCENDIARY",
        Enabled = true,
      },
      ["1108334355"] = {
        HashKey = "COMPONENT_AT_SIGHTS",
        Name = "Holographic Sight",
        Description = "Accurate sight for close quarters combat.",
        Enabled = true,
      },
      ["1141059345"] = {
        HashKey = "COMPONENT_CARBINERIFLE_MK2_CLIP_FMJ",
        Name = "Full Metal Jacket Rounds",
        Description = "Increased damage to vehicles. Also penetrates bullet resistant and bulletproof vehicle glass. Reduced capacity.",
        AmmoType = "AMMO_RIFLE_FMJ",
        Enabled = true,
      },
      ["1283078430"] = {
        HashKey = "COMPONENT_CARBINERIFLE_MK2_CLIP_01",
        Name = "Default Clip",
        Description = "Standard capacity for regular ammo.",
        IsDefault = true
      },
      ["1303784126"] = {
        HashKey = "COMPONENT_AT_MUZZLE_07",
        Name = "Split-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["1574296533"] = {
        HashKey = "COMPONENT_CARBINERIFLE_MK2_CLIP_02",
        Name = "Extended Clip",
        Description = "Extended capacity for regular ammo.",
        Enabled = true,
      },
      ["2076495324"] = {
        HashKey = "COMPONENT_AT_AR_FLSH",
        Name = "Flashlight",
        Description = "Aids low light target acquisition.",
        Enabled = true,
      },
      ["2201368575"] = {
        HashKey = "COMPONENT_AT_CR_BARREL_01",
        Name = "Default Barrel",
        Description = "Stock barrel attachment.",
        IsDefault = true
      },
      ["2205435306"] = {
        HashKey = "COMPONENT_AT_AR_SUPP",
        Name = "Suppressor",
        Description = "Reduces noise and muzzle flash.",
        Enabled = true,
      },
      ["2335983627"] = {
        HashKey = "COMPONENT_AT_CR_BARREL_02",
        Name = "Heavy Barrel",
        Description = "Increases damage dealt to long-range targets.",
        Enabled = true,
      },
      ["2640679034"] = {
        HashKey = "COMPONENT_AT_AR_AFGRIP_02",
        Name = "Grip",
        Description = "Improves weapon accuracy.",
        Enabled = true,
      },
      ["3113485012"] = {
        HashKey = "COMPONENT_AT_MUZZLE_01",
        Name = "Flat Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3328927042"] = {
        HashKey = "COMPONENT_AT_SCOPE_MEDIUM_MK2",
        Name = "Large Scope",
        Description = "Extended-range zoom functionality.",
        Enabled = true,
      },
      ["3362234491"] = {
        HashKey = "COMPONENT_AT_MUZZLE_02",
        Name = "Tactical Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3725708239"] = {
        HashKey = "COMPONENT_AT_MUZZLE_03",
        Name = "Fat-End Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
      ["3968886988"] = {
        HashKey = "COMPONENT_AT_MUZZLE_04",
        Name = "Precision Muzzle Brake",
        Description = "Reduces recoil during rapid fire.",
        Enabled = true,
      },
    },
  },
  ["4256991824"] = {
    HashKey = "WEAPON_SMOKEGRENADE",
    Name = "Tear Gas",
    Description = "Tear gas grenade, particularly effective at incapacitating multiple assailants. Sustained exposure can be lethal.",
    Group = "GROUP_THROWN",
    Enabled = true,
    Components = { },
  }
}

return cfg