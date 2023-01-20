---@diagnostic disable: redefined-local
if not vRP.modules.logsystem then return end

local LogSystem = class("LogSystem", vRP.Extension)

function LogSystem:__construct()
    self.cfg = module("cfg/logs")

    self.selectedTarget = self.cfg.selectedTarget
    self.targetConfig = self.cfg.targetConfig[self.selectedTarget]

    if self.selectedTarget == "file" then
        if not os.execute("cd " .. self.targetConfig) then
            os.execute("mkdir " .. self.targetConfig)
        end
    elseif self.selectedTarget == "database" then
        vRP:prepare("vRP_LogSystem/createTable",
            [[
            CREATE TABLE IF NOT EXISTS `vrp_logs` (
                `id` INT(11) NOT NULL AUTO_INCREMENT,
                `log_type` TEXT NOT NULL COLLATE 'utf8mb3_general_ci',
                `value` TEXT NOT NULL COLLATE 'utf8mb3_general_ci',
                `created_at` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
                PRIMARY KEY (`id`) USING BTREE                
            )
        ]])

        vRP:prepare("vRP_LogSystem/addlog", "INSERT INTO vrp_logs (log_type, `value`)	VALUES (@logtype, @logvalue)")

        async(function()
            vRP:execute("vRP_LogSystem/createTable")
        end)
    end

    self.SaveToFile = function(dest, message)
        if not (dest or message) then return end

        local fd = self.targetConfig .. "/" .. dest .. ".txt"
        local file = io.open(fd, "a+")

        if file then
            local currentDate = os.date("%c")
            file:write("[ " .. currentDate .. " ] " .. message .. "\n")
            file:close()
        end
    end

    self.SaveToDatabase = function(destId, message)
        if not (destId or message) then return end
        vRP:execute("vRP_LogSystem/addlog", { logtype = destId, logvalue = message })
    end

    self.SendToDiscord = function(webhook, message)
        if not (webhook or message) then return end
        PerformHttpRequest(webhook, function() end, "POST",
            json.encode({
                content = "```prolog\n" .. message .. "```"
            }), { ['Content-Type'] = 'application/json' })
    end


    vRP.Extension.__construct(self)
end

LogSystem.proxy = {}

--PROXY TEST
function LogSystem.proxy:registerLog(destId, params)
    if not self.cfg.destiny[destId] then return end
    local message = self.cfg.destiny[destId].template:format(table.unpack(params))
    if self.selectedTarget == "database" then
        self.SaveToDatabase(destId, message:gsub("\n", " "))
    elseif self.selectedTarget == "file" then
        self.SaveToFile(destId, message:gsub("\n", " "))
    elseif self.selectedTarget == "print" then
        print("LogSystem", "^3" .. destId .. "^0", message:gsub("\n", " "))
    else
        self.SendToDiscord(self.cfg.destiny[destId].webhook, message)
    end
end

vRP:registerExtension(LogSystem)
