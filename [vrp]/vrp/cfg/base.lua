
local cfg = {}

-- mysql credentials
cfg.db = {
  driver = "oxmysql",
  host = "127.0.0.1",
  database = "vRP",
  user = "vRP",
  password = ""
}

cfg.server_id = "main" -- identify the server (ex: in database)

cfg.save_interval = 60 -- seconds

-- delay the tunnel at loading (for weak connections)
cfg.load_duration = 30 -- seconds, player duration in loading mode at the first spawn
cfg.load_delay = 30 -- milliseconds, delay the tunnel communication when in loading mode
cfg.global_delay = 0 -- milliseconds, delay the tunnel communication when not in loading mode

cfg.max_characters = 5 -- maximum number of characters per user
cfg.character_select_delay = 60 -- minimum number of seconds between character selects, at least 30 seconds is recommended

-- If enabled, will not use the IP address to identify players (recommended, solve same IP issue; other identifiers should be available).
cfg.ignore_ip_identifier = true

cfg.lang = "en"

cfg.log_level = 0 -- maximum verbose level for logs, -1 may disable logs and 1000 may print all logs

-- metrics printing control (when enabled the central metrics reporter will include custom module metrics)
cfg.metrics = {
  enabled = true,
  -- if true the metrics reporter will print custom metrics regardless of `cfg.log_level`
  force_print = true
}

-- metrics startup collection: perform a one-time full Lua GC after startup and record before/after memory
cfg.metrics.collect_on_start = true

-- optional threshold-based GC during runtime: set to >0 to enable (KB)
cfg.metrics.gc_threshold_kb = 2000
cfg.metrics.gc_on_threshold = true

-- this list of resources is auto started after starting vrp
cfg.moduals = {
	-- database should be first
	"vrp_oxmysql"
}

-- Basic ANSI Color Codes
cfg.codes = {
	color = {
		black = 30,
		red = 31,
		green = 32,
		yellow = 33,
		blue = 34,
		magenta = 35,
		cyan = 36,
		white = 37,
	},
	background = {
		black = 40,
    red = 41,
    green = 42,
    yellow = 43,
    blue = 44,
    magenta = 45,
    cyan = 46,
    white = 47,
	},
	style = {
		bold = 1,
    dim = 2,
    underline = 4,
	},
  defaults = {
    ver = { color = 32, style = 1 },
    img = {color = 36, style = 2},
    dev = {color = 36, style = 4},
  }
}

cfg.server_name = "vRP Framework"

cfg.framework_info = {
    version = "vRP version 3.0.0",
    server_img = [[
	                        RRRRRRRRRRRRRRRRR    PPPPPPPPPPPPPPPPP   
                         R::::::::::::::::R   P::::::::::::::::P  
                         R::::::RRRRRR:::::R  P::::::PPPPPP:::::P 
                         RR:::::R     R:::::R PP:::::P     P:::::P
vvvvvvv           vvvvvvv  R::::R     R:::::R   P::::P     P:::::P
 v:::::v         v:::::v   R::::R     R:::::R   P::::P     P:::::P
  v:::::v       v:::::v    R::::RRRRRR:::::R    P::::PPPPPP:::::P 
   v:::::v     v:::::v     R:::::::::::::RR     P:::::::::::::PP  
    v:::::v   v:::::v      R::::RRRRRR:::::R    P::::PPPPPPPPP    
     v:::::v v:::::v       R::::R     R:::::R   P::::P            
      v:::::v:::::v        R::::R     R:::::R   P::::P            
       v:::::::::v         R::::R     R:::::R   P::::P            
        v:::::::v        RR:::::R     R:::::R PP::::::PP          
         v:::::v         R::::::R     R:::::R P::::::::P          
          v:::v          R::::::R     R:::::R P::::::::P          
           vvv           RRRRRRRR     RRRRRRR PPPPPPPPPP
		]],
  dev_build = "Dev Build 0.0"
}

return cfg
