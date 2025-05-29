-- Loaded client-side and server-side.
--
-- Enable/disable modules (some may be required by others).
-- It's recommended to disable things from the modules configurations directly if possible.

local modules = {
  admin = true,
  group = true,
  gui = true,
  map = true,
  weather = true,
  misc = true,
  command = true,
  player_state = true,
  weapon = true,
  user = true,
  identity = true,
  money = true,
  logs = true, -- discord logs
  hours = true, -- hours module
}

return modules
