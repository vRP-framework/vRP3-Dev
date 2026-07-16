if not Shared.DevelopmentMode then 
    return
end 

RegisterCommand('popupForm', function()
    local status, data = Core.PopupForm({
        title = "Form Title", -- string: Title of the popup
        message = "Form Popup", -- string: Message/description
        yes = "Confirm", -- string: Label for confirm button
        no = "Cancel", -- string: Label for cancel button
        img = "https://picsum.photos/300/150", -- string: URL for image
        fields = {
            {
                uid = "uid_1", -- string: Unique identifier for the field [REQUIRED]
                field_type = "input", -- string: "input" | "selectDropdown" [REQUIRED]
                
                -- Input field options
                placeholder = "Enter value", -- string
                label = "", -- string
                type = "text", -- string: "text" | "number"
                min = nil, -- number | nil
                max = nil, -- number | nil
                maxLength = nil, -- number | nil
                icon = "fas fa-user", -- string: Font Awesome icon class
                iconPlacement = "right", -- string: "left" | "right"
                iconBg = true, -- boolean
                autoFocus = true, -- boolean
                class = "", -- string: Additional CSS class
            },
            {
                uid = "uid_2", -- string: Unique identifier [REQUIRED]
                field_type = "selectDropdown", -- string: "input" | "selectDropdown" [REQUIRED]

                -- Select dropdown options 
                options = { -- [REQUIRED]
                    { uid = "option_1", text = "Option 1", icon = "fas fa-star" }, -- uid: string, text: string, icon: string, disabled?: boolean
                    { uid = "option_2", text = "Option 2", icon = "fas fa-heart", disabled = false }, -- disabled: boolean
                },
                selectedUid = false, -- false | string (uid)
                disabled = false, -- boolean
                searchable = false, -- boolean
                searchPlaceholder = "Search options...", -- string
                noResultsText = "No results found", -- string
                emptyText = "No options available", -- string
                autoSelectFirst = true, -- boolean
                title = "", -- string (optional title above dropdown)
                placement = "bottom", -- string: "bottom" | "top"
            },
        },
    })
    print("Popup Form Result: ", status, Core.DumpTable(data))
end)

-- Test command for Required Items UI
RegisterCommand('requiredItems', function()
    Core.ShowRequiredItems({
        title = "Required Items",
        checkAmount = true, -- true: checks inventory, false: just displays items
        items = {
            { name = "money", amount = 1 },
            { name = "weapon_pistol", amount = 1 },
            { name = "weapon_assaultRifle", amount = 1 }
        }
    })
    
    -- Auto hide after 5 seconds for testing
    SetTimeout(5000, function()
        Core.HideRequiredItems()
    end)
end)

local model = `prop_mp_cone_02`
local offsetModel = `bkr_prop_weed_table_01b`
RegisterCommand('testGizmo', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped) + GetEntityForwardVector(ped) * 3

    RequestModel(offsetModel)
    while not HasModelLoaded(offsetModel) do
        Wait(10)
    end
    local objOffset = CreateObject(offsetModel, coords.x, coords.y, coords.z, false, false, false)
    FreezeEntityPosition(objOffset, true)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    local offset = GetOffsetFromEntityInWorldCoords(objOffset, 0, 3, 0)
    
    local obj = CreateObject(model, offset.x, offset.y, offset.z, false, false, false)
    FreezeEntityPosition(obj, true)

    local data = useGizmo(obj, objOffset, {
        distance = 1.0,      -- distance from the reference entity
        height = 2.0,        -- height above the reference entity
        angle = 0.0,         -- angle around the reference entity (degrees)
        fov = 60.0,          -- field of view
        transitionTime = 500, -- camera transition time in ms
        lookAtOffset = vector3(2.0, 0.0, 1.0) -- offset from reference entity to look at
    })
    if DoesEntityExist(obj) then
        DeleteEntity(obj)
    end
    if DoesEntityExist(objOffset) then
        DeleteEntity(objOffset)
    end
end)