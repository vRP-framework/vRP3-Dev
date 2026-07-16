-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.logs then return end

local lang = vRP.lang
local Logs = class("Logs", vRP.Extension)

-- METHODS

function Logs:__construct()
  vRP.Extension.__construct(self)

	self.cfg = module("vrp", "cfg/logs")
	self.server_name = vRP.cfg.server_name
	self.server_icon = self.cfg.server_icon
	self.sufix = self.cfg.sufix
	self.avatar_url = self.cfg.avatar_url
	self.embeds_author_url = self.cfg.embeds.author.url
	self.embeds_color = self.cfg.embeds.colors.blue

	-- copy webhooks and small fields then free cfg to reduce memory
	self.webhooks = self.cfg.webhooks
	self.cfg = nil
end

-- send a message on discord with webhooks api, // https://birdie0.github.io/discord-webhooks-guide/discord_webhook.html javascript example
function Logs:discordLog(webhook, data)
   if not webhook or webhook == "" then 
      return false, self:log("invalid webhook") 
   end
   if not data then 
      return false, self:log("invalid data") 
   end

   -- Ensure default values for avatar_url
   data.avatar_url = data.avatar_url or self.avatar_url

   -- Prepare embeds if present
   if data.embeds then
      for i = 1, #data.embeds do
         local embed = data.embeds[i]

         embed.title = embed.title and "**__"..embed.title.."__**" or "**__"..self.server_name.."__**"
         embed.author = embed.author or {
            name = self.server_name,
            url = self.embeds_author_url,
            icon_url = self.server_icon
         }
         embed.color = embed.color or self.embeds_color
         embed.footer = embed.footer or { text = self.server_name }
         embed.timestamp = os.date("!%Y%m%dT%H%M%S").."Z"
      end
   end

   local encoded_data = json.encode(data)

   -- Send to each webhook if a table of webhooks is passed
   if type(webhook) == "table" then
      for _, link in pairs(webhook) do
         PerformHttpRequest(link, self.handleDiscordResponse, "POST", encoded_data, {["Content-Type"] = "application/json"})
      end
      return true
   else
      -- Send to a single webhook
      PerformHttpRequest(webhook, self.handleDiscordResponse, "POST", encoded_data, {["Content-Type"] = "application/json"})
      return true
   end
end

-- Handles Discord responses and logs errors
function Logs:handleDiscordResponse(err, text, headers)
   if err and err ~= 204 then
      Logs:error("Error sending to Discord: "..err)
      return false, err
   end
   return true
end

Logs.event = {}

-- send a message on discord when a player connects
function Logs.event:playerJoin(user)
	self:discordLog(self.webhooks and self.webhooks.player_join or nil, {
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
	self:discordLog(self.webhooks and self.webhooks.player_leave or nil, {
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
	self:discordLog(self.webhooks and self.webhooks.player_death or nil, {
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
