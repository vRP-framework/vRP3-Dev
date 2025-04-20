return {
	debug = true,
	enableHud = true,

	['defaultData'] = {
		['age'] = 21,
		['bank'] = {
			['cash'] = 500,
			['checking'] = {
				['account'] = math.random(1000,9999)..'-'..math.random(1000,9999),
				['balance'] = 100,
			},
			['savings'] = {
				['account'] = math.random(1000,9999)..'-'..math.random(1000,9999),
				['balance'] = 50,
			},
		}
	},

	spawnLocations = {
		['Harmony'] = {
			id = 'harmony',
			coords = {337.1813, -289.9784, 99.5026}, -- camera coords
			rotation = {-90.0, 0.0, 0.0}, -- cam rotation
			spawnCoords = {323.4967, -230.0344, 54.1085}, -- player spawn coords
		},
		['LS Airport'] = {
			id= 'lsairport',
			coords = {-991.0665, -2653.3745, 53.6523},
			rotation = {-20.0, 0.0, 160.0},
			spawnCoords = {-1042.3120, -2745.6702, 21.3594},
		},
		['Mirror Park'] = {
			id= 'mirrorpark',
			coords = {1357.0961, -345.1201, 402.0004},
			rotation = {-50.0, 0.0, 140.0},
			spawnCoords = {1196.9158, -502.6990, 65.2535},
		},
	},
}