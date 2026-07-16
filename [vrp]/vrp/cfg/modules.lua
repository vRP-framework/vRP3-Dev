-- Loaded client-side and server-side.
--
-- Enable/disable modules (some may be required by others).
-- It's recommended to disable things from the modules configurations directly if possible.

local modules = {
	-- core
  admin = true,
  group = true,
  gui = true,
  map = true,
  player_state = true,
  user = true,
  identity = true,
	money = true,
	
	-- utility
	transformer = true,
	
	-- Sub Modules
	aptitude = true,
	weapon = true, 
	weather = true,
	misc = true,
  command = true,
	logs = true, 				-- discord logs
	vehicle = true				--leak
}

return modules
