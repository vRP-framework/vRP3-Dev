local cfg = {}

cfg.area_radius = 1.5
cfg.area_height = 2.0

-- flat purchase price per category; a business entry's own `price` field
-- (if set) overrides this. Tune these numbers directly here, no code change.
cfg.category_prices = {
	food = 15000,
	tools = 40000,
	chemicals = 60000,
	drugstore = 35000,
	gear = 50000,
	melee_weapons = 25000,
	handguns = 70000,
	barber = 20000,
	tattoo = 18000,
}

-- recurring maintenance/utility fees, drawn from each business's own capital
-- balance (not the owner's wallet/bank). Default fee = rate * the business's
-- effective price (its own `price` override or category_prices[kind]); a
-- business entry can also set `daily_fee`/`utility_fee` directly to bypass
-- the rate calculation entirely. Billed lazily by elapsed real time in
-- Business:runFeeSweep, not on a fixed wall-clock tick.
cfg.daily_fee_rate = 0.003
cfg.utility_fee_rate = 0.005

-- per-kind rate overrides -- any kind not listed here just falls back to the
-- flat daily_fee_rate/utility_fee_rate/daily_revenue_rate above. Rough
-- real-world-informed starting points reflecting typical overhead/margin
-- differences between business types (not hard research) -- retune freely,
-- no code change needed.
cfg.daily_fee_rate_by_kind = {
	food = 0.0035,      -- thin-margin, high-volume retail: modest overhead
	tools = 0.0030,
	chemicals = 0.0040, -- specialized/regulated handling costs more to run
	drugstore = 0.0030,
	gear = 0.0030,
	melee_weapons = 0.0025,
	handguns = 0.0045,  -- regulated retail: licensing/security overhead
	barber = 0.0020,    -- low-overhead service shop
	tattoo = 0.0020,
}
cfg.utility_fee_rate_by_kind = {
	chemicals = 0.0060,
	handguns = 0.0065,  -- regulated retail: heavier utility/compliance cost
}
cfg.daily_revenue_rate_by_kind = {
	-- baseline simulated ambient/NPC-driven revenue for every kind, so an
	-- inventory-backed store isn't a pure expense sink while waiting on the
	-- not-yet-built real point-of-sale system -- rough real-world-margin
	-- ballpark per category, not hard research, retune freely
	food = 0.006,          -- thin-margin but high-volume retail
	tools = 0.009,
	chemicals = 0.007,
	drugstore = 0.009,
	gear = 0.010,
	melee_weapons = 0.008,
	handguns = 0.006,      -- regulated retail: thinner net margin despite high price
	barber = 0.008,        -- real-world barbershop net margins run ~15-20%
	tattoo = 0.012,         -- tattoo parlors typically run fatter margins (low material cost)
}

-- +/- day-to-day fluctuation applied to every computed fee/revenue amount
-- (e.g. 15 = each cycle rolls somewhere in the +/-15% band around the base
-- rate) so profit doesn't read as a dead-flat number every single cycle.
-- Set to 0 to disable and go back to fully static amounts.
cfg.revenue_fee_variance_pct = 15

cfg.utility_period_days = 7 -- how often the utility fee is charged
cfg.grace_period_days = 30 -- how long a negative balance is tolerated before repossession
cfg.payroll_period_days = 7 -- how often accrued staff wages become due (matches the "per payroll cycle" wage wording)

-- real seconds treated as one in-game "day" for daily/utility/payroll/grace
-- cycles (utility_period_days/grace_period_days/payroll_period_days above
-- are all multiples of this) -- deliberately an IN-GAME day, not a real
-- calendar day, so "7 days" of fees/payroll actually elapses over 7
-- day/night cycles for someone playing regularly, not 7 real-life days.
-- Default (2880s = 48 real minutes) matches FXServer/GTA's standard
-- in-game day length at the default clock speed (SetMillisecondsPerGameMinute
-- 2000, same default `client/weather.lua`'s Weather.normal uses). If this
-- server's day/night cycle speed is permanently changed from that default,
-- update this to match -- it is not read from the live clock automatically
-- (client/weather.lua's freeze/speed/slow are per-admin-session client-side
-- toggles with no persistent server-side authority to read from).
cfg.day_length = 2880

-- seconds between sweep passes (billing itself is elapsed-time based, this
-- just controls how often it's checked) -- kept well under day_length so a
-- full in-game day/night cycle doesn't pass between checks unnoticed
cfg.fee_sweep_interval = 300

-- every kind gets a simulated baseline daily revenue (ambient/NPC-driven
-- average sales), billed into balance alongside the daily fee in the same
-- sweep pass -- real player-purchase revenue for inventory-backed kinds is
-- future work (no point-of-sale system exists yet) and would stack on top
-- of this baseline once built, not replace it, since baseline-only revenue
-- from actual player traffic alone would be too sparse to keep a business
-- afloat. Same rate*effective-price / per-business-override shape as the
-- fees above (a business entry can set `daily_revenue` directly).
cfg.daily_revenue_rate = 0.010

-- passive-income kinds: these have nothing to sell (no inventory
-- dependency) -- they'll never get a real player-purchase revenue stream on
-- top of the baseline above, unlike the inventory-backed kinds once selling
-- is built. Kept for that documentation purpose (and possible future
-- staffing/roadmap use), no longer gates whether baseline revenue applies.
cfg.passive_kinds = { barber = true, tattoo = true }

-- key = unique business id, also the persistence key suffix ("vRP:business:"<id>)
-- kind: category tag, looked up in cfg.category_prices for the default price;
--       also usable later to find "all food stores" etc. without touching
--       this table's shape.
--
-- purchasing intentionally stays marker-only (walking up to the location),
-- not available from the remote "My Businesses" phone menu -- each store
-- kind's actual pricing/stock/selling logic is planned as its own separate
-- addon/script plugged into this framework later, so purchase flow for
-- those store types will most likely live there instead of in core.
cfg.businesses = {
	["food_1"] = {
		kind = "food", title = "Food Store #1",
		pos = vec3(128.1410369873, -1286.1120605469, 29.281036376953),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_2"] = {
		kind = "food", title = "Food Store #2",
		pos = vec3(-47.522762298584, -1756.85717773438, 29.4210109710693),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_3"] = {
		kind = "food", title = "Food Store #3",
		pos = vec3(25.7454013824463, -1345.26232910156, 29.4970207214355),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_4"] = {
		kind = "food", title = "Food Store #4",
		pos = vec3(1135.57678222656, -981.78125, 46.4157981872559),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_5"] = {
		kind = "food", title = "Food Store #5",
		pos = vec3(1163.53820800781, -323.541320800781, 69.2050552368164),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_6"] = {
		kind = "food", title = "Food Store #6",
		pos = vec3(374.190032958984, 327.506713867188, 103.566368103027),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_7"] = {
		kind = "food", title = "Food Store #7",
		pos = vec3(2555.35766601563, 382.16845703125, 108.622947692871),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_8"] = {
		kind = "food", title = "Food Store #8",
		pos = vec3(2676.76733398438, 3281.57788085938, 55.2411231994629),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_9"] = {
		kind = "food", title = "Food Store #9",
		pos = vec3(1960.50793457031, 3741.84008789063, 32.3437385559082),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_10"] = {
		kind = "food", title = "Food Store #10",
		pos = vec3(1393.23828125, 3605.171875, 34.9809303283691),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_11"] = {
		kind = "food", title = "Food Store #11",
		pos = vec3(1166.18151855469, 2709.35327148438, 38.15771484375),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_12"] = {
		kind = "food", title = "Food Store #12",
		pos = vec3(547.987609863281, 2669.7568359375, 42.1565132141113),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_13"] = {
		kind = "food", title = "Food Store #13",
		pos = vec3(1698.30737304688, 4924.37939453125, 42.0636749267578),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_14"] = {
		kind = "food", title = "Food Store #14",
		pos = vec3(1729.54443359375, 6415.76513671875, 35.0372200012207),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_15"] = {
		kind = "food", title = "Food Store #15",
		pos = vec3(-3243.9013671875, 1001.40405273438, 12.8307056427002),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_16"] = {
		kind = "food", title = "Food Store #16",
		pos = vec3(-2967.8818359375, 390.78662109375, 15.0433149337769),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_17"] = {
		kind = "food", title = "Food Store #17",
		pos = vec3(-3041.17456054688, 585.166198730469, 7.90893363952637),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_18"] = {
		kind = "food", title = "Food Store #18",
		pos = vec3(-1820.55725097656, 792.770568847656, 138.113250732422),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_19"] = {
		kind = "food", title = "Food Store #19",
		pos = vec3(-1486.76574707031, -379.553985595703, 40.163387298584),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_20"] = {
		kind = "food", title = "Food Store #20",
		pos = vec3(-1223.18127441406, -907.385681152344, 12.3263463973999),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["tools_1"] = {
		kind = "tools", title = "Tools Store",
		pos = vec3(-707.408996582031, -913.681701660156, 19.2155857086182),
		_config = { map_entity = {"PoI", {blip_id = 402, blip_color = 47, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,150,0,100}}} },
	},
	["chemicals_1"] = {
		kind = "chemicals", title = "Chemical Supplier",
		pos = vec3(1163.79260253906, 2705.58544921875, 38.1576995849609),
		_config = { map_entity = {"PoI", {blip_id = 140, blip_color = 5, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,255,0,100}}} },
	},
	["drugstore_1"] = {
		kind = "drugstore", title = "Drugstore",
		pos = vec3(-497.977142333984, -328.329895599, 34.501636505127),
		_config = { map_entity = {"PoI", {blip_id = 51, blip_color = 27, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,0,255,100}}} },
	},
	["gear_1"] = {
		kind = "gear", title = "Gear Shop",
		pos = vec3(844.76324462891, -1029.4772949219, 28.194856643677),
		_config = { map_entity = {"PoI", {blip_id = 110, blip_color = 1, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,0,0,100}}} },
	},
	["melee_weapons_1"] = {
		kind = "melee_weapons", title = "Melee Weapons Shop",
		pos = vec3(21.70, -1107.41, 29.79),
		_config = { map_entity = {"PoI", {blip_id = 141, blip_color = 1, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,0,0,100}}} },
	},
	["handguns_1"] = {
		kind = "handguns", title = "Handgun Shop",
		pos = vec3(844.299, -1033.26, 28.1949),
		_config = { map_entity = {"PoI", {blip_id = 110, blip_color = 1, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,0,0,100}}} },
	},

	-- barber/tattoo: passive-income proof of concept, no inventory
	-- dependency (see cfg.passive_kinds above). Barber positions are
	-- user-verified in-game locations. Tattoo positions are best-effort
	-- placeholders, not yet verified -- walk to each and adjust `pos`.
	["barber_1"] = {
		kind = "barber", title = "Barber Shop (Vespucci)",
		pos = vec3(-813.71356201172, -184.06265258789, 37.56893157959),
		_config = { map_entity = {"PoI", {blip_id = 71, blip_color = 5, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,255,255,100}}} },
	},
	["barber_2"] = {
		kind = "barber", title = "Barber Shop (Vinewood)",
		pos = vec3(136.97842407227, -1707.8671875, 29.291620254517),
		_config = { map_entity = {"PoI", {blip_id = 71, blip_color = 5, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,255,255,100}}} },
	},
	["barber_3"] = {
		kind = "barber", title = "Barber Shop (La Mesa)",
		pos = vec3(-1282.8363037109, -1116.9685058594, 6.9901127815247),
		_config = { map_entity = {"PoI", {blip_id = 71, blip_color = 5, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,255,255,100}}} },
	},
	["barber_4"] = {
		kind = "barber", title = "Barber Shop (Paleto Bay)",
		pos = vec3(1931.7169189453, 3730.3142089844, 32.844432830811),
		_config = { map_entity = {"PoI", {blip_id = 71, blip_color = 5, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,255,255,100}}} },
	},
	["barber_5"] = {
		kind = "barber", title = "Barber Shop (Great Ocean Hwy)",
		pos = vec3(1212.4298095703, -472.55453491211, 66.2080078125),
		_config = { map_entity = {"PoI", {blip_id = 71, blip_color = 5, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,255,255,100}}} },
	},
	["barber_6"] = {
		kind = "barber", title = "Barber Shop (Rockford Hills)",
		pos = vec3(-32.703586578369, -152.55470275879, 57.076503753662),
		_config = { map_entity = {"PoI", {blip_id = 71, blip_color = 5, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,255,255,100}}} },
	},
	["barber_7"] = {
		kind = "barber", title = "Barber Shop (Grapeseed)",
		pos = vec3(-278.02655029297, 6228.3115234375, 31.695518493652),
		_config = { map_entity = {"PoI", {blip_id = 71, blip_color = 5, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,255,255,100}}} },
	},
	["tattoo_1"] = {
		kind = "tattoo", title = "Tattoo Parlor (Downtown)",
		pos = vec3(315.68, 180.72, 103.19),
		_config = { map_entity = {"PoI", {blip_id = 75, blip_color = 27, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,0,255,100}}} },
	},
	["tattoo_2"] = {
		kind = "tattoo", title = "Tattoo Parlor (Vespucci)",
		pos = vec3(-1153.79, -1424.51, 4.96),
		_config = { map_entity = {"PoI", {blip_id = 75, blip_color = 27, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,0,255,100}}} },
	},
}

return cfg
