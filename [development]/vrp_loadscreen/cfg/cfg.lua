local cfg = {}

-- Placeholder branding -- swap for your real server name whenever ready.
cfg.server_name = "Server Name"

-- Used only when the connecting client has no saved theme preference yet.
-- Players can always switch via the swatches in the corner of the loading
-- screen -- their pick is then remembered in that client's local storage.
-- Valid values: "heist", "vice", "modern".
cfg.default_theme = "heist"

-- Placeholder rotating tips (plain center text, no box) -- helpful/
-- informational, not rules. Replace once you have real ones. NOTE:
-- html/js/script.js keeps its own DEFAULT_TIPS copy so these can start
-- the instant the page renders, before this Lua config even reaches the
-- client -- update both when you change this list.
cfg.tips = {
  "New here? Type /help in chat to see available commands.",
  "Found a bug or a rule-breaker? Report it with /report.",
  "Your loading screen theme is saved automatically -- pick your favorite with the swatches in the corner.",
  "Toggle the loading screen music with the speaker icon in the top right.",
}

-- Placeholder rotating rules (left-hand panel) -- basic generic RP server
-- rules, meant as a starting point. Review and replace with your actual
-- ruleset. Same NOTE as cfg.tips above -- html/js/script.js has its own
-- DEFAULT_RULES copy, update both together.
cfg.rules = {
  "No RDM (Random Death Match) -- don't kill or attack players without valid, established roleplay.",
  "No VDM (Vehicle Death Match) -- don't use vehicles as weapons outside of legitimate RP scenarios.",
  "No metagaming -- using out-of-character info (streams, Discord, OOC chat) in-character is not allowed.",
  "No powergaming -- give others a real chance to react; don't force unavoidable outcomes on them.",
  "Value your life -- roleplay realistic fear and self-preservation in dangerous situations.",
  "Respect the New Life Rule (NLR) -- your character forgets the events leading up to their death.",
  "Initiate before engaging -- proper RP initiation is required before combat.",
  "No exploiting bugs or glitches for personal or group advantage.",
}

-- Rotating common-keybind reference (right-hand panel). Freely editable --
-- just plain display strings, no key-code binding happens here, this is
-- purely a player-facing reference list. Displayed cfg.keybinds_per_slide
-- at a time per rotation instead of one at a time. Same NOTE as
-- cfg.tips/cfg.rules above -- html/js/script.js has its own
-- DEFAULT_KEYBINDS copy, update both together.
cfg.keybinds = {
  "W / A / S / D -- Move",
  "SHIFT -- Sprint",
  "CTRL -- Crouch",
  "E -- Interact / Enter Vehicle",
  "TAB -- Inventory",
  "M -- Map",
  "F1 -- Phone",
  "H -- Horn",
  "B -- Seatbelt",
  "L -- Flashlight",
}

-- How many cfg.keybinds entries show at once per rotation (4-5 reads well
-- in the side panel's width -- much more than that starts wrapping/
-- overflowing).
cfg.keybinds_per_slide = 5

-- NOTE: html/js/script.js has its own DEFAULT_AUDIO copy of these same
-- values so playback can start the instant the page renders (see the tips
-- note above) -- update both when you change this.
cfg.audio = {
  volume = 0.5,  -- 0.0 - 1.0, initial volume before the player mutes/adjusts
  autoplay = true,
  loop = true,
}

-- ms to wait after vRP confirms the character is ready before telling the
-- client (purely cosmetic breathing room server-side, not a loading
-- dependency -- separate from cfg.initializing_duration_ms below, which is
-- the client-side equivalent).
cfg.close_delay = 300

-- Extra fixed buffer client.lua's close() waits out AFTER vRP itself
-- confirms the character is ready, before it even starts the fade-out --
-- the NUI shows "Initializing..." with a chunked, stop-and-go simulated
-- fill for this long (see script.js's animateFill). Not tied to any real
-- loading signal, it's just safety margin ("ensure proper loading") to
-- smooth over any straggling client-side setup. The player is invisible
-- and unattackable for this whole window (see client.lua's playerSpawned
-- handler and the end of its close() chain, which is what clears it).
cfg.initializing_duration_ms = 10000

-- Everything from here drives the NUI's "Loading Character Data..." step
-- specifically (the FINAL simulated step, shown after "Loading Server
-- Data..." -- see script.js's startCharacterData/startServerData for how
-- the two are told apart). Not tied to any real vRP data-loading signal.
-- Runs for this long...
cfg.character_data_duration_ms = 10000

-- ...and the loading screen is held open for this much *extra* time after
-- that step visually finishes, before the fade-out even starts -- so the
-- screen never disappears right as "Loading Character Data" hits 100%.
cfg.character_data_extra_ms = 1000

-- ms client.lua waits after telling the NUI to fade out (so the CSS
-- fade-overlay transition actually gets to play) before it runs
-- ShutdownLoadingScreenNui for real -- keep in sync with style.css's
-- .fade-overlay transition duration (currently 0.65s).
cfg.close_fade_ms = 700

return cfg
