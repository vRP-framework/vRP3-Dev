-- CREDITS
-- https://forum.cfx.re/t/allow-drawgizmo-to-be-used-outside-of-fxdk/5091845/8?u=demi-automatic
-- https://github.com/overextended/ox_lib/tree/master
-- https://github.com/DemiAutomatic/object_gizmo
-- Credit: https://github.com/citizenfx/lua/blob/luaglm-dev/cfx/libs/scripts/examples/dataview.lua
-- to minimize unnecessary dependencies, script has been adapted and modified for devhub_lib

local objectGizmoDataview = setmetatable({
    EndBig = ">",
    EndLittle = "<",
    Types = {
        Int8 = { code = "i1" },
        Uint8 = { code = "I1" },
        Int16 = { code = "i2" },
        Uint16 = { code = "I2" },
        Int32 = { code = "i4" },
        Uint32 = { code = "I4" },
        Int64 = { code = "i8" },
        Uint64 = { code = "I8" },
        Float32 = { code = "f", size = 4 }, -- a float (native size)
        Float64 = { code = "d", size = 8 }, -- a double (native size)

        LuaInt = { code = "j" }, -- a lua_Integer
        UluaInt = { code = "J" }, -- a lua_Unsigned
        LuaNum = { code = "n" }, -- a lua_Number
        String = { code = "z", size = -1, }, -- zero terminated string
    },

    FixedTypes = {
        String = { code = "c" }, -- a fixed-sized string with n bytes
        Int = { code = "i" }, -- a signed int with n bytes
        Uint = { code = "I" }, -- an unsigned int with n bytes
    },
}, {
    __call = function(_, length)
        return objectGizmoDataview.ArrayBuffer(length)
    end
})
objectGizmoDataview.__index = objectGizmoDataview

--[[ Create an ArrayBuffer with a size in bytes --]]
function objectGizmoDataview.ArrayBuffer(length)
    return setmetatable({
        blob = string.blob(length),
        length = length,
        offset = 1,
        cangrow = true,
    }, objectGizmoDataview)
end

--[[ Wrap a non-internalized string --]]
function objectGizmoDataview.Wrap(blob)
    return setmetatable({
        blob = blob,
        length = blob:len(),
        offset = 1,
        cangrow = true,
    }, objectGizmoDataview)
end

--[[ Return the underlying bytebuffer --]]
function objectGizmoDataview:Buffer() return self.blob end
function objectGizmoDataview:ByteLength() return self.length end
function objectGizmoDataview:ByteOffset() return self.offset end
function objectGizmoDataview:SubView(offset, length)
    return setmetatable({
        blob = self.blob,
        length = length or self.length,
        offset = 1 + offset,
        cangrow = false,
    }, objectGizmoDataview)
end

--[[ Return the Endianness format character --]]
local function ef(big) return (big and objectGizmoDataview.EndBig) or objectGizmoDataview.EndLittle end

--[[ Helper function for setting fixed datatypes within a buffer --]]
local function packblob(self, offset, value, code)
    -- If cangrow is false the objectGizmoDataview represents a subview, i.e., a subset
    -- of some other string view. Ensure the references are the same before
    -- updating the subview
    local packed = self.blob:blob_pack(offset, code, value)
    if self.cangrow or packed == self.blob then
        self.blob = packed
        self.length = packed:len()
        return true
    else
        return false
    end
end

--[[
    Create the API by using objectGizmoDataview.Types
--]]
for label,datatype in pairs(objectGizmoDataview.Types) do
    if not datatype.size then  -- cache fixed encoding size
        datatype.size = string.packsize(datatype.code)
    elseif datatype.size >= 0 and string.packsize(datatype.code) ~= datatype.size then
        local msg = "Pack size of %s (%d) does not match cached length: (%d)"
        error(msg:format(label, string.packsize(datatype.code), datatype.size))
        return nil
    end

    objectGizmoDataview["Get" .. label] = function(self, offset, endian)
        offset = offset or 0
        if offset >= 0 then
            local o = self.offset + offset
            local v,_ = self.blob:blob_unpack(o, ef(endian) .. datatype.code)
            return v
        end
        return nil
    end

    objectGizmoDataview["Set" .. label] = function(self, offset, value, endian)
        if offset >= 0 and value then
            local o = self.offset + offset
            local v_size = (datatype.size < 0 and value:len()) or datatype.size
            if self.cangrow or ((o + (v_size - 1)) <= self.length) then
                if not packblob(self, o, value, ef(endian) .. datatype.code) then
                    error("cannot grow subview")
                end
            else
                error("cannot grow objectGizmoDataview")
            end
        end
        return self
    end
end

for label,datatype in pairs(objectGizmoDataview.FixedTypes) do
    datatype.size = -1 -- Ensure cached encoding size is invalidated

    objectGizmoDataview["GetFixed" .. label] = function(self, offset, typelen, endian)
        if offset >= 0 then
            local o = self.offset + offset
            if (o + (typelen - 1)) <= self.length then
                local code = ef(endian) .. "c" .. tostring(typelen)
                local v,_ = self.blob:blob_unpack(o, code)
                return v
            end
        end
        return nil -- Out of bounds
    end

    objectGizmoDataview["SetFixed" .. label] = function(self, offset, typelen, value, endian)
        if offset >= 0 and value then
            local o = self.offset + offset
            if self.cangrow or ((o + (typelen - 1)) <= self.length) then
                local code = ef(endian) .. "c" .. tostring(typelen)
                if not packblob(self, o, value, code) then
                    error("cannot grow subview")
                end
            else
                error("cannot grow objectGizmoDataview")
            end
        end
        return self
    end
end

local enableScale = false -- allow scaling mode. doesnt scale collisions and resets when physics are applied it seems
local isCursorActive = false
local gizmoEnabled = false
local isRelative = false
local currentEntity
local wasCancelled = false
local isOffsetMode = false
local initialPosition = nil
local referenceEntity = nil

-- FUNCTIONS

local function normalize(x, y, z)
    local length = math.sqrt(x * x + y * y + z * z)
    if length == 0 then
        return 0, 0, 0
    end
    return x / length, y / length, z / length
end

local function makeEntityMatrix(entity)
    local f, r, u, a = GetEntityMatrix(entity)
    local view = objectGizmoDataview.ArrayBuffer(60)

    view:SetFloat32(0, r[1])
        :SetFloat32(4, r[2])
        :SetFloat32(8, r[3])
        :SetFloat32(12, 0)
        :SetFloat32(16, f[1])
        :SetFloat32(20, f[2])
        :SetFloat32(24, f[3])
        :SetFloat32(28, 0)
        :SetFloat32(32, u[1])
        :SetFloat32(36, u[2])
        :SetFloat32(40, u[3])
        :SetFloat32(44, 0)
        :SetFloat32(48, a[1])
        :SetFloat32(52, a[2])
        :SetFloat32(56, a[3])
        :SetFloat32(60, 1)

    return view
end

local function applyEntityMatrix(entity, view)
    local x1, y1, z1 = view:GetFloat32(16), view:GetFloat32(20), view:GetFloat32(24)
    local x2, y2, z2 = view:GetFloat32(0), view:GetFloat32(4), view:GetFloat32(8)
    local x3, y3, z3 = view:GetFloat32(32), view:GetFloat32(36), view:GetFloat32(40)
    local tx, ty, tz = view:GetFloat32(48), view:GetFloat32(52), view:GetFloat32(56)

    if not enableScale then
        x1, y1, z1 = normalize(x1, y1, z1)
        x2, y2, z2 = normalize(x2, y2, z2)
        x3, y3, z3 = normalize(x3, y3, z3)
    end

    SetEntityMatrix(entity,
        x1, y1, z1,
        x2, y2, z2,
        x3, y3, z3,
        tx, ty, tz
    )
end

-- LOOPS

local function gizmoLoop(entity)
    if not gizmoEnabled then
        return LeaveCursorMode()
    end

    EnterCursorMode()
    isCursorActive = true

    if IsEntityAPed(entity) then
        SetEntityAlpha(entity, 200)
    else
        SetEntityDrawOutline(entity, true)
    end
    
    while gizmoEnabled and DoesEntityExist(entity) do
        Wait(0)
        if IsControlJustPressed(0, 47) then -- G
            if isCursorActive then
                LeaveCursorMode()
                isCursorActive = false
            else
                EnterCursorMode()
                isCursorActive = true
            end
        end
        DisableControlAction(0, 24, true)  -- lmb
        DisableControlAction(0, 25, true)  -- rmb
        DisableControlAction(0, 140, true) -- r
        DisablePlayerFiring(PlayerPedId(), true)


        local matrixBuffer = makeEntityMatrix(entity)
        local changed = Citizen.InvokeNative(0xEB2EDCA2, matrixBuffer:Buffer(), 'Editor1',
            Citizen.ReturnResultAnyway())

        if changed then
            applyEntityMatrix(entity, matrixBuffer)
        end
    end
    
    
    if isCursorActive then
        LeaveCursorMode()
    end
    isCursorActive = false

    if DoesEntityExist(entity) then
        if IsEntityAPed(entity) then SetEntityAlpha(entity, 255) end
        SetEntityDrawOutline(entity, false)
    end

    gizmoEnabled = false
    currentEntity = nil
end

local function GetVectorText(vectorType) 
    if not currentEntity then return 'ERR_NO_ENTITY_' .. (vectorType or "UNK") end
    local label = (vectorType == "coords" and "Position" or "Rotation")
    local vec = (vectorType == "coords" and GetEntityCoords(currentEntity) or GetEntityRotation(currentEntity))
    return ('%s: %.2f, %.2f, %.2f'):format(label, vec.x, vec.y, vec.z)
end

local function textUILoop()
    CreateThread(function()
        Core.ShowControlButtons(
            '<kbd>G</kbd> Cursor Mode <br>' ..
            '<kbd>R</kbd> Rotate Mode  <br>' ..
            '<kbd>LALT</kbd> Snap To Ground  <br>' ..
            '<kbd>ENTER</kbd> Done Editing  <br>' ..
            '<kbd>ESC</kbd> Cancel  <br>')
        while gizmoEnabled do
            Wait(250)
        end
        Core.ShowControlButtons(false)
    end)
end


-- EXPORTS
local currentRotationStatus = 'translate'
local activeCamera = nil

local function createGizmoCamera(refEntity, cameraData)
    if not refEntity or not DoesEntityExist(refEntity) then return nil end
    
    local refCoords = GetEntityCoords(refEntity)
    local distance = cameraData.distance or 5.0
    local height = cameraData.height or 2.0
    local angle = cameraData.angle or 0.0
    local fov = cameraData.fov or 50.0
    local lookAtOffset = cameraData.lookAtOffset or vector3(0.0, 0.0, 0.0)
    
    -- Calculate camera position based on angle around the reference entity
    local rad = math.rad(angle)
    local camX = refCoords.x + (distance * math.sin(rad))
    local camY = refCoords.y + (distance * math.cos(rad))
    local camZ = refCoords.z + height
    
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, camX, camY, camZ)
    
    -- Point camera at entity with offset
    local lookAtCoords = GetOffsetFromEntityInWorldCoords(refEntity, lookAtOffset.x, lookAtOffset.y, lookAtOffset.z)
    PointCamAtCoord(cam, lookAtCoords.x, lookAtCoords.y, lookAtCoords.z)
    
    SetCamFov(cam, fov)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, cameraData.transitionTime or 500, true, true)
    
    return cam
end

local function destroyGizmoCamera(transitionTime)
    if activeCamera then
        RenderScriptCams(false, true, transitionTime or 500, true, true)
        DestroyCam(activeCamera, false)
        activeCamera = nil
    end
end

local function useGizmo(entity, offsetProp, cameraData)
    gizmoEnabled = true
    currentEntity = entity
    wasCancelled = false
    if currentRotationStatus == 'rotate' then
        currentRotationStatus = 'translate'
        ExecuteCommand('-gizmoRotation')
        ExecuteCommand('+gizmoTranslation')
    end

    -- offsetProp can be an entity handle to calculate offset relative to
    if offsetProp and type(offsetProp) ~= "boolean" and DoesEntityExist(offsetProp) then
        isOffsetMode = true
        referenceEntity = offsetProp
        initialPosition = GetEntityCoords(offsetProp)
        
        -- Create camera if cameraData is provided and offsetProp is an entity
        if cameraData then
            activeCamera = createGizmoCamera(offsetProp, cameraData)
        end
    elseif offsetProp == true then
        isOffsetMode = true
        referenceEntity = nil
        initialPosition = GetEntityCoords(entity)
        
        -- Create camera looking at the entity itself if cameraData is provided
        if cameraData then
            activeCamera = createGizmoCamera(entity, cameraData)
        end
    else
        isOffsetMode = false
        referenceEntity = nil
        initialPosition = nil
    end
    
    textUILoop()
    gizmoLoop(entity)
    
    -- Cleanup camera when gizmo is done
    destroyGizmoCamera(cameraData and cameraData.transitionTime or 500)

    return {
        handle = entity,
        position = GetEntityCoords(entity),
        rotation = GetEntityRotation(entity),
        cancelled = wasCancelled
    }
end

exports("useGizmo", useGizmo)  -- No need to upload this functionality to all scripts

local function gizmoAddKeybind(data)
    data.name = 'devhub_lib'..data.name
    RegisterCommand('+' .. data.name, function()
        if data.disabled or IsPauseMenuActive() then return end
        data.isPressed = true
        if data.onPressed then data:onPressed() end
    end)

    RegisterCommand('-' .. data.name, function()
        if data.disabled or IsPauseMenuActive() then return end
        data.isPressed = false
        if data.onReleased then data:onReleased() end
    end)
    RegisterKeyMapping('+' .. data.name, data.description, data.defaultMapper or "keyboard", data.defaultKey)
end

-- CONTROLS these execute the existing gizmo commands but allow me to add additional logic to update the mode display.

gizmoAddKeybind({
    name = '_gizmoSelect',
    description = 'Selects the currently highlighted gizmo',
    defaultMapper = 'MOUSE_BUTTON',
    defaultKey = 'MOUSE_LEFT',
    onPressed = function(self)
        if not gizmoEnabled then return end
        ExecuteCommand('+gizmoSelect')
    end,
    onReleased = function (self)
        ExecuteCommand('-gizmoSelect')
    end
})

gizmoAddKeybind({
    name = '_gizmoRotation',
    description = 'Sets mode for the gizmo',
    defaultKey = 'R',
    onPressed = function(self)
        if not gizmoEnabled then return end
        if currentRotationStatus == 'translate' then
            currentRotationStatus = 'rotate'
            ExecuteCommand('-gizmoTranslation')
            ExecuteCommand('+gizmoRotation')
        else
            currentRotationStatus = 'translate'
            ExecuteCommand('-gizmoRotation')
            ExecuteCommand('+gizmoTranslation')
        end
    end,
    onReleased = function (self)
        -- no action on release
    end
})

gizmoAddKeybind({
    name = '_gizmoclose',
    description = 'Close gizmo',
    defaultKey = 'RETURN',
    onReleased = function(self)
        if not gizmoEnabled then return end
        
        local coords = GetEntityCoords(currentEntity)
        local rotation = GetEntityRotation(currentEntity)
        local clipboardText
        
        if isOffsetMode and initialPosition then
            -- Calculate the local offset from the reference entity's coordinate space
            local refEntity = referenceEntity or currentEntity
            local offset
            
            if referenceEntity and DoesEntityExist(referenceEntity) then
                -- Use GetOffsetFromEntityGivenWorldCoords for accurate coordinate conversion
                offset = GetOffsetFromEntityGivenWorldCoords(referenceEntity, coords.x, coords.y, coords.z)
            else
                -- Fallback to simple world difference if no reference entity
                local refPos = initialPosition
                offset = coords - refPos
            end
            
            clipboardText = ('offset = vector3(%.4f, %.4f, %.4f), rotation = vector3(%.4f, %.4f, %.4f)'):format(
                offset.x, offset.y, offset.z,
                rotation.x, rotation.y, rotation.z
            )
        else
            clipboardText = ('coords = vector3(%.4f, %.4f, %.4f), rotation = vector3(%.4f, %.4f, %.4f)'):format(
                coords.x, coords.y, coords.z,
                rotation.x, rotation.y, rotation.z
            )
        end
        print(clipboardText)
        Core.CopyClipboard(clipboardText)
        Core.Notify("Copied to clipboard", 3000, "success")
        
        gizmoEnabled = false
    end,
})

gizmoAddKeybind({
    name = '_gizmoSnapToGround',
    description = 'Snap current gizmo object to floor/surface',
    defaultKey = 'LMENU',
    onPressed = function(self)
        if not gizmoEnabled then return end
        PlaceObjectOnGroundProperly_2(currentEntity)
    end,
})

gizmoAddKeybind({
    name = '_gizmoCancel',
    description = 'Cancel gizmo and delete entity',
    defaultKey = 'ESCAPE',
    onReleased = function(self)
        if not gizmoEnabled then return end
        wasCancelled = true
        gizmoEnabled = false
    end,
})

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if gizmoEnabled then
        wasCancelled = true
        gizmoEnabled = false
    end
    destroyGizmoCamera(0)
end)


RegisterCommand('testdialog', function()
    local coords = vec4(1727.8600, 3322.8416, 40.2235, 193.7808)
    
    -- spawn ped
    local pedModel = `a_m_m_farmer_01`
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(0)
    end
    
    local ped = CreatePed(4, pedModel, coords.x, coords.y, coords.z, coords.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)

    local npc = {
        name = "Bob Grass",
        role = "Citizen",
        icon = 'fas fa-user',
        camera = { -- @table (optional) camera settings for npc dialog
            distance = 0.85, -- @number (optional) camera distance from npc, default 0.85
            height = 0.65, -- @number (optional) camera height offset, default 0.65
        },
        animation = { -- @table (optional) animation to play on npc when dialog opens
            dict = "gestures@m@standing@casual", -- @string (required) animation dictionary
            name = "gesture_shrug_hard", -- @string (required) animation name
            blendIn = 8.0, -- @number (optional) blend in speed, default 8.0
            blendOut = -8.0, -- @number (optional) blend out speed, default -8.0
            duration = -1, -- @number (optional) animation duration in ms, -1 for full length, default -1
            flag = 2, -- @number (optional) animation flags (0 = normal, 1 = repeat, 2 = stop on last frame, etc.), default 1
            playbackRate = 0, -- @number (optional) playback rate, default 0
        },
    }
    
    local result = Core.NpcDialog(ped, {
        npc = npc,
        soundFile = 'https://upload.devhub.gg/dh_upload/soundSample.mp3',
        text = "We are happy to present the new devhub script license manager. Take your server to new heights with our unique features, making what was previously impossible a reality. Features include a license generator, fake license creation, license stealing detection, and a license scanner, among many others.",
        grid = {
            {
                uid = "talk_bob", -- @string (required) unique identifier for the option
                icon = 'fas fa-comment', -- @string (required) fontawesome icon class
                title = "Talk to Bob",  -- @string (required) option title, can be html
                badge = { -- @table (optional) badge config
                    text = "Aggressive action", -- @string (optional) can be html
                    color = "#ff0000", -- @string (optional) badge background color
                },
                span = 2, -- @number (optional) makes the option span 2 columns
            },
            {
                uid = "buy_items",
                icon = 'fas fa-shopping-cart',
                title = "Buy items",
            },
            {
                uid = "give_money",
                icon = 'fas fa-dollar-sign',
                title = "Give him money",
            },
            {
                uid = "goodbye",
                icon = 'fas fa-times',
                title = "Goodbye",
            }
        },
    })
    print("Dialog result - Status: " .. tostring(result.status), json.encode(result.data))

    if result.status then
        if result.data == 'goodbye' then
            Core.CloseNpcDialog()
        elseif result.data == 'give_money' then
            local result = Core.NpcDialog(entity, {
                npc = npc,
                text = "Dialog text here", -- @string (required) dialog text
                input = {
                    type = "number", -- @string (required) type of input: "number" or "text"
                    default = 3, -- @number or @string (required) default value
                    text = "I can give you %s dollars.", -- @string (required) text with %s placeholder for input value
                    buttonText = "Give", -- @string (required) button text
                    inputWidth = "3vw", -- @string (optional) width of the input field
                    min = 1, -- @number (optional) [type number] min number value
                    max = 1000, -- @number (optional) [type number] max number value
                    maxLength = 7, -- @number (optional) [type text] only for type text
                    hint = { -- @table (optional) hints for input values
                        number = { -- [type number]
                            [5] = "A small amount", -- from 0 to first option
                            [50] = "A moderate amount", -- from first option to second
                            [500] = "A large amount",
                            [1000] = "An extremely large amount",
                        },
                        text = { -- [type text]
                            ['orange'] = "Orange is not what im looking for",
                            ['banana'] = "Banana is what i need",
                        },
                    }
                },
            })
            print("Dialog result - Status: " .. tostring(result.status), json.encode(result.data))
        elseif result.data == 'buy_items' then
            -- Payment method selection example
            local paymentResult = Core.NpcDialog(ped, {
                npc = npc,
                text = "How would you like to pay for your items?",
                paymentMethod = {
                    default = "cash", -- cash selected by default
                    buttonText = "Proceed",
                    cashLabel = "Cash",
                    cardLabel = "Card",
                },
            })
            print("Payment method result - Status: " .. tostring(paymentResult.status), json.encode(paymentResult.data))
            -- paymentResult.data.method will be "cash" or "card"
        end
    end
    
    -- Clean up ped after dialog
    DeleteEntity(ped)
    SetModelAsNoLongerNeeded(pedModel)
end)