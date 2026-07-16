local ClothingData = {
    variations = {
        ["mask"] = 1,
        ["gloves"] = 3,
        ["pants"] = 4,
        ["backpack"] = 5,
        ["boots"] = 6,
        ["neckless"] = 7,
        ["tshirt"] = 8,
        ["vest"] = 9,
        ["decals"] = 10,
        ["torso"] = 11,
    },
    props = {
        ["hat"] = 0,
        ["glasses"] = 1,
        ["ears"] = 2,
        ["watch"] = 6,
        ["bracelets"] = 7,
    }
}  

local PreviousClothing = {}

RegisterNetEvent("dh_lib:changeClothing:client", function(clothingConfig)
    SetPlayerOutfit(clothingConfig)
end)

RegisterNetEvent("dh_lib:resetClothing:client", function()
    SetPreviousClothing()
end)
 
function SetPlayerOutfit(clothingConfig)
    SetPreviousClothing()
    local ped = PlayerPedId()
    for category, value in pairs(clothingConfig) do
        if ClothingData.variations[category] then
            PreviousClothing[category] = {GetPedDrawableVariation(ped, ClothingData.variations[category]), GetPedTextureVariation(ped, ClothingData.variations[category])}
            SetPedComponentVariation(ped, ClothingData.variations[category], value[1], value[2], 2)
        elseif ClothingData.props[category] then
            PreviousClothing[category] = {GetPedPropIndex(ped, ClothingData.props[category]), GetPedPropTextureIndex(ped, ClothingData.props[category])}
            SetPedPropIndex(ped, ClothingData.props[category], value[1], value[2], true)
        end
    end 
end

function SetPreviousClothing()
    local ped = PlayerPedId()
    for category, value in pairs(PreviousClothing) do
        if ClothingData.variations[category] then
            SetPedComponentVariation(ped, ClothingData.variations[category], value[1], value[2], 2)
        elseif ClothingData.props[category] then
            if value[1] == -1 then
                ClearPedProp(ped, ClothingData.props[category])
            else 
                SetPedPropIndex(ped, ClothingData.props[category], value[1], value[2]+1, true)
            end
        end
    end
    PreviousClothing = {}
end 