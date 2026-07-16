local cfg = {}

-- enable debug mode to see all users(including self) in contact list
cfg.debug = true

cfg.db = false -- enable database storage

-- ui already hides entries after 25
cfg.transactions = {
	limit = false, 			-- toggle this
	max = 100          	-- max number of transactions to keep in history
}

cfg.admin_permission = "player.kick"

cfg.padValue = 4
cfg.startValue = 0

cfg.default_avatar = {
	"https://api.dicebear.com/7.x/avataaars/svg?seed=allen",
	"https://api.dicebear.com/7.x/avataaars/svg?seed=alex",
	"https://api.dicebear.com/7.x/avataaars/svg?seed=Bob",	
	"https://api.dicebear.com/7.x/avataaars/svg?seed=britt",
	"https://api.dicebear.com/7.x/avataaars/svg?seed=john",
	"https://api.dicebear.com/7.x/avataaars/svg?seed=jane"
}

cfg.keys = {
	["E"] = 206,
	["ESC"] = 322,
}

cfg.marker = {
	-- marker https://docs.fivem.net/docs/game-references/blips/
	--color={r,g,b,a}
	bank = {
		"PoI",{ blip_id = 431, blip_color = 25, marker_id = 1, scale = {1.0,1.0,1.0}, color={255, 0, 0, 255}}
	},
	atm = {
		"PoI",{ blip_id = 108, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color={0, 0, 255, 255}}
	}
}

cfg.atms = {
  --{Name, Gtype, Cords}
	{"Vinewood", 		"Atm", 89.577018737793,2.16031360626221,68.322021484375},           -- 7131 (Vinewood)
	{"Little Seoul", 	"Atm", -526.497131347656,-1222.79455566406,18.4549674987793},       -- 8254 (Little Seoul)
	{"Little Bluffs", 	"Atm", -2072.48413085938,-317.190521240234,13.315972328186},        -- 7001 (Little Bluffs)
	{"Little Seoul", 	"Atm", -821.565551757813,-1081.90270996094,11.1324348449707},       -- 8127 (Little Seoul)
	{"Grapeseed", 		"Atm", 1686.74694824219,4815.8828125,42.0085678100586},             -- 2010 (Grapeseed)
	{"Paleto", 			"Atm", -386.899444580078,6045.78466796875,31.5001239776611},        -- 1036 (Paleto)
	{"Harmony", 		"Atm", 1171.52319335938,2702.44897460938,38.1754684448242},         -- 4024 (Harmony - Left)
	{"Harmony", 		"Atm", 1172.46,2702.51,38.17},                                      -- 4024 (Harmony - Right)
	{"24/7", 			"Atm", 1968.11157226563,3743.56860351563,32.3437271118164},         -- 3008 Sandy Shores 24/7
	{"Route 15", 		"Atm", 2558.85815429688,351.045166015625,108.621520996094},         -- 7354 (Route 15)
	{"Mirror Park", 	"Atm", 1153.75634765625,-326.805023193359,69.2050704956055},        -- 7302 (Mirror Park)
	{"LTD", 			"Atm", -56.9172439575195,-1752.17590332031,29.4210166931152},       -- 9094 (Grove - LTD)
	{"Chumash", 		"Atm", -3241.02856445313,997.587158203125,12.5503988265991},        -- 5038 (Chumash)
	{"North Rockford", 	"Atm", -1827.1884765625,784.907104492188,138.302581787109},         -- 5016 (North Rockford)
	{"Zancudo", 		"Atm", -1091.54748535156,2708.55786132813,18.9437484741211},        -- 5004 (Route 68 - Zancudo)
	{"Downtown", 		"Atm", 112.45637512207,-819.25048828125,31.3392715454102},          -- 8055 (Downtown LS)
	{"Peacful", 		"Atm", -256.173187255859,-716.031921386719,33.5202751159668},       -- 8067 (Peacful/San Andreas)
	{"Ron", 			"Atm", 174.227737426758,6637.88623046875,31.5730476379395},         -- 1012 (Paleto - Ron)
	{"Little Soul", 	"Atm", -660.727661132813,-853.970336914063,24.484073638916},        -- 8141 (Little Seoul)
	{"Route 13", 		"Atm", 2682.89,3286.69,55.24},                                      -- 3051 (Route 13)
	{"Hospital", 		"Atm", 1822.59,3683.11,34.28},                                      -- 3004 (Sandy Shores Hospital)
	{"Harmony", 		"Atm", 540.27,2671.07,42.16},                                       -- 4019 (Route 68 - Harmony)
	{"Grapeseed", 		"Atm", 1703.03,4933.57,42.06},                                      -- 2006 (Grapeseed)
	{"Route 1", 		"Atm", 1735.3717041016,6410.8706054688,35.037223815918},            -- 1000 (Route 1)
	{"City Hall", 		"Atm", -577.19830322266,-194.90817260742,38.219688415527},          -- 7248 (City Hall - Interior)
	{"City Hall", 		"Atm", -537.29486083984,-171.72114562988,38.219593048096},          -- 7248 (City Hall - Interior)
	{"City Hall", 		"Atm", -527.71936035156,-166.33560180664,38.226531982422},          -- 7248 (City Hall - Interior)
	{"City Hall", 		"Atm", -567.82458496094,-199.2407989502,33.419609069824},           -- 7248 (City Hall - Interior)
	{"City Hall", 		"Atm", -567.72119140625,-234.51927185059,34.24275970459},           -- 7248 (City Hall - Interior)
	{"City Hall", 		"Atm", -588.40026855469,-140.97332763672,47.201053619385},          -- 7229 (City Hall - Interior)
	{"City Hall", 		"Atm", -587.32391357422,-142.16612243652,47.201053619385},          -- 7229 (City Hall - Interior)
	{"City Hall", 		"Atm", -586.49212646484,-143.18655395508,47.201053619385},          -- 7229 (City Hall - Interior)
	{"Ron", 			"Atm", 155.54043579102,6642.5341796875,31.611328125},               -- 1012 (Paleto - Ron)
	{"Paleto", 			"Atm", -97.123474121094,6455.2744140625,31.463478088379},           -- 1055 (Paleto - Bank Left)
	{"Paleto", 			"Atm", -95.303596496582,6456.8994140625,31.458686828613},           -- 1055 (Paleto - Bank Right)
	{"Paleto", 			"Atm", -132.97325134277,6366.5405273438,31.475481033325},           -- 1052 (Paleto)
	{"Ammunation", 		"Atm", 1702.5053710938,3757.712890625,34.36351776123},              -- 3018 (Sandy Shores - Ammunation)
	{"UTool", 			"Atm", 2742.0307617188,3464.7263183594,55.67024230957},             -- 3052 (UTool - Interior)
	{"aChumashtm", 		"Atm", -3240.857421875,1008.6438598633,12.830717086792},            -- 5037 (Chumash)
	{"Route 1", 		"Atm", -3144.0854492188,1127.4614257813,20.855289459229},           -- 5033 (Chumash - Route 1)
	{"Chumash", 		"Atm", -3044.0258789063,594.64617919922,7.7362442016602},           -- 5047 (Chumash)
	{"South Chumash", 	"Atm", -3041.0131835938,593.10736083984,7.9089283943176},           -- 5047 (South Chumash)
	{"South Chumash", 	"Atm", -2975.6713867188,380.09069824219,14.997392654419},           -- 5065 (South Chumash)
	{"South Chumash", 	"Atm", -2959.0625,488.09817504883,15.463918685913},                 -- 5070 Right (South Chumash)
	{"South Chumash", 	"Atm", -2956.921875,488.00723266602,15.463918685913},               -- 5070 Left (South Chumash)
	{"Morningwood", 	"Atm", -1204.6551513672,-326.05938720703,37.834045410156},          -- 7176 Left (Morningwood)
	{"Morningwood", 	"Atm", -1205.3619384766,-324.55853271484,37.858551025391},          -- 7176 Right (Morningwood)
	{"Little Soul", 	"Atm", -717.41754150391,-915.61694335938,19.215591430664},          -- 8140 (Little Seoul)
	{"Rockford Hills", 	"Atm", -866.19909667969,-187.57279968262,37.662826538086},          -- 7209 Left (Rockford Hills)
	{"Rockford Hills", 	"Atm", -867.08349609375,-185.82484436035,37.683982849121},          -- 7209 Right (Rockford Hills)
	{"Pacific Standard", "Atm", 236.72535705566,218.43037414551,106.28675079346},            -- 7090 (Pacific Standard Bank Left)
	{"Pacific Standard", "Atm", 237.53016662598,216.62673950195,106.28675079346},            -- 7090 (Pacific Standard Bank Rigth)
	{"Vinewood", 		"Atm", 380.89553833008,323.62399291992,103.56636810303},            -- 7093 (Vinewood)
	{"Vinewood", 		"Atm", 527.10034179688,-160.74494934082,57.085674285889},           -- 7283 (Vinewood)
	{"Vespucci Fleeca", "Atm", 147.74327087402,-1035.5285644531,29.343046188354},           -- 8170 (Vespucci Fleeca - Left)
	{"Vespucci Fleeca", "Atm", 146.20881652832,-1034.9339599609,29.344745635986},           -- 8170 (Vespucci Fleeca - Right)
	{"South Los Santos", "Atm", 288.51113891602,-1256.8619384766,29.440755844116},           -- 9051 (South Los Santos)
	{"South Los Santos", "Atm", 33.171524047852,-1347.8913574219,29.497024536133},           -- 9046 (South Los Santos)
	{"Vanilla Unicorn", "Atm", 128.81535339355,-1291.3045654297,29.269548416138},           -- 9047 (Vanilla Unicorn - Interior Left)
	{"Vanilla Unicorn", "Atm", 129.81828308105,-1292.8364257813,29.269548416138},           -- 9047 (Vanilla Unicorn - Interior Right)
	{"Maze", 			"Atm", -261.47845458984,-2012.7548828125,30.145603179932},          -- 9006 (Maze Bank - Right)
	{"Maze", 			"Atm", -272.63497924805,-2024.9252929688,30.145601272583},          -- 9006 (Maze Bank - Left)
	{"Vespucci PD", 	"Atm", -1110.4315185547,-836.67156982422,19.00152015686},           -- 8090 (Vespucci PD)
	{"Mosely's Auto", 	"Atm", -31.398092269897,-1659.7408447266,29.479095458984},          -- 9092 (Mosely's Auto)
	{"Vinewood", 		"Atm", 258.3014831543,-260.76187133789,54.03857421875},             -- 7192 (Vinewood)
	{"Legion Square", 	"Atm", 311.1637878418,-910.96356201172,29.293626785278},            -- 8050 (Bahama Mamas - Legion Square)
	{"Del Perro", 		"Atm", -1390.9208984375,-590.53857421875,30.319561004639},          -- 7219 (Bahama Mamas - Del Perro)
}

cfg.banks = {
  --{Name, Gtype, Cords}
	{"Meteor", 				"Bank", 314.18591308594,-278.43823242188,54.170776367188},  		-- Fleeca (Hawick/Meteor)
	{"Blaine County", 		"Bank", -112.32825469971,6468.9008789063,31.626708984375},  		-- Blaine County Savings (Paleto Bay)
	{"Grapeseed", 			"Bank", -112.32825469971,6468.9008789063,31.626708984375},  		-- Fleeca (Grapeseed Main Street)
	{"Harmony", 			"Bank", 1176.3131103516,2706.3518066406,38.09769821167},    		-- Fleeca (Harmony Route 68)
	{"North Rockford", 		"Bank", -1214.0821533203,-331.38815307617,37.790714263916}, 		-- Fleeca (North Rockford)
	{"Pacific Standard", 	"Bank", 246.15174865723,223.03652954102,106.2868347168},    		-- Pacific Standard Bank (Vinewood)
	{"South Chumash", 		"Bank", -2962.9086914063,481.56585693359,15.706773757935},  		-- Fleeca (South Chumash Route 1)
	{"Legion Square", 		"Bank", 148.67407226563,-1040.1070556641,29.377759933472},  		-- Fleeca (Legion Square)
	{"Hawick", 				"Bank", -352.15078735352,-49.039798736572,49.046245574951},		--Hawick and San Vitutus 7185
}

return cfg