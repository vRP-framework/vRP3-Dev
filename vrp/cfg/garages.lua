local cfg = {}

cfg.options = {
    interactionDistance = 1.5,
    returnInteractionDistance = 3.0,
    renderDistance = 100.0,
    renderDelay = 1000,
    showSpawnsAsBlips = true,
    showGaragesAsBlips = true,
    anyGarageLocation = true,
    returnToAnyGarage = true,
    showBlipsForVehicles = true,
}

cfg.classToType = {
    [0] = "car",         --compacts
    [1] = "car",         --sedans
    [2] = "car",         --suvs
    [3] = "car",         --coupes
    [4] = "car",         --muscle
    [5] = "car",         --sportsclassics
    [6] = "car",         --sports
    [7] = "car",         --super
    [8] = "bike",        --motorcycles
    [9] = "car",         --offroad
    [10] = "commercial", --industrial
    [11] = "commercial", --utility
    [12] = "car",        --vans
    [13] = "bike",       --cycles
    [14] = "boat",       --boats
    [15] = "helicopter", --helicopters
    [16] = "plane",      --planes
    [17] = "service",    --service
    [18] = "emergency",  --emergency
    [19] = "military",   --military
    [20] = "commercial", --commercial
    [21] = "trains",     --trains
}


cfg.garages = {
    ["legion"] = {
        name = "Legion",
        types = { "car", "bike" },
        groups = { "user" },
        pickLocation = vec3(213.6791, -809.3231, 30.0149),
        returnLocation = vec3(234.7412, -785.9277, 29.51),
        spawnLocations = {
            vec4(225.3230, -793.9541, 30.6740, 251.0345),
            vec4(236.2293, -800.8922, 30.4409, 67.2911),
            vec4(237.9775, -792.7291, 30.5062, 69.6357),
            vec4(223.5213, -784.5111, 30.7579, 80.7351),
            vec4(215.0383, -775.8243, 30.8622, 244.7993),
            vec4(215.0383, -775.8243, 30.8622, 244.7993)
        }
    },


}

return cfg
