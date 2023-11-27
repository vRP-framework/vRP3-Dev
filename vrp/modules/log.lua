-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.logs then return end

local lang = vRP.lang
local Logs = class("Logs", vRP.Extension)

-- METHODS

function Logs:__construct()
   vRP.Extension.__construct(self)

   self.cfg = module("vrp", "cfg/logs")
end

-- send a message on discord with webhooks api, // https://birdie0.github.io/discord-webhooks-guide/discord_webhook.html javascript example
function Logs:discordLog(webhook, data) -- webhook (string/webhooks table), data (table)
   if not webhook or webhook == "" then return false, Logs:log("invalid webhook") end -- 1 = invalid webhook
   if not data then return false, Logs:log("invalid data") end -- 2 = invalid data

   if not data.username then data.username = self.cfg.sufix.." Logs" else data.username = self.cfg.sufix.." "..data.username end
   if not data.avatar_url then data.avatar_url = self.cfg.avatar_url end

   if data.embeds then
      for i=1, #data.embeds do
         local embed = data.embeds[i]

         if not embed.title then
            embed.title = "**__"..vRP.cfg.server_name.."__**"
         else
            embed.title = "**__"..embed.title.."__**"
         end

         if not embed.author then
            embed.author = {
               name = vRP.cfg.server_name,
               url = self.cfg.embeds.author.url,
               icon_url = self.cfg.server_icon
            }
         end

         if not embed.color then
            embed.color = self.cfg.embeds.colors.blue
         end

         if not embed.footer then
            embed.footer = {}
            embed.footer.text = vRP.cfg.server_name
         else
            embed.footer.text = embed.footer.text.."\n"..vRP.cfg.server_name
         end

         data.embeds[i].timestamp = os.date("!%Y%m%dT%H%M%S").."Z"
      end
   end

   local encoded_data = json.encode(data)
   if type(webhook) == "table" then
      for link in pairs(webhook) do
         PerformHttpRequest(link, function(err, text, headers)
            if err and err ~= 204 then
               Logs:error("Error: "..err)
               return false, err -- return error // https://discord.com/developers/docs/topics/opcodes-and-status-codes
            end
         end, "POST", encoded_data, {["Content-Type"] = "application/json"})

         return true
      end
   else
      PerformHttpRequest(webhook, function(err, text, headers)
         if err and err ~= 204 then
            Logs:error("Error: "..err)
            return false, err -- return error // https://discord.com/developers/docs/topics/opcodes-and-status-codes
         end

         return true
      end, "POST", encoded_data, {["Content-Type"] = "application/json"})
   end
end

Logs.event = {}

-- send a message on discord when a player connects
function Logs.event:playerJoin(user)
   self:discordLog(self.cfg.webhooks.player_join, {
      username = lang.logs.player_join.username({}),
      embeds = {
         {
            title = lang.logs.player_join.title({vRP.getPlayerName(user.source), user.id}),
            description = lang.logs.player_join.description({vRP.getPlayerName(user.source), user.id}),
         }
      }
   })
end

-- send a message on discord when a player disconnects
function Logs.event:playerLeave(user, reason)
   self:discordLog(self.cfg.webhooks.player_leave, {
      username = lang.logs.player_leave.username(),
      embeds = {
         {
            title = lang.logs.player_leave.title({vRP.getPlayerName(user.source), user.id}),
            description = lang.logs.player_leave.description({vRP.getPlayerName(user.source), user.id}),
            fields = {
               {
                  name = lang.logs.player_leave.fields.name({}),
                  value = lang.logs.player_leave.fields.reason({reason or "Unknown"}),
                  inline = true,
               }
            }
         }
      }
   })
end

-- send a discord message when a player dies
function Logs.event:playerDeath(user)
   self:discordLog(self.cfg.webhooks.player_death, {
      username = lang.logs.player_death.username({}),
      embeds = {
         {
            title = lang.logs.player_death.title({vRP.getPlayerName(user.source), user.id}),
            description = lang.logs.player_death.description({vRP.getPlayerName(user.source), user.id}),
         }
      }
   })
end

vRP:registerExtension(Logs)
