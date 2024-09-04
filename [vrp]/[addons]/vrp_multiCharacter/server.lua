local Multi = class("Multi_Character", vRP.Extension)
Multi.event = {}
Multi.tunnel = {}

function Multi:__construct()
    vRP.Extension.__construct(self)
end 

function Multi.event:playerSpawn(user, first_spawn)
  if first_spawn and user:isReady() then
    self.remote._close(user.source)
    --self.tunnel_interface:getCharacters(user)
  end
end

function Multi.tunnel:getCharacters()
  local user = vRP.users_by_source[source]
  local characters = user:getCharacters()
  for _, cid in pairs(characters) do
    local identity = vRP.EXT.Identity:getIdentity(cid)
    local firstname, name, age = identity.firstname, identity.name, identity.age
    vRP:log(firstname.." "..name.." "..age)
  end
end

vRP:registerExtension(Multi)