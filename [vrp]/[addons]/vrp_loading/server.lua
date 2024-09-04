local Loading = class("Loading", vRP.Extension)
Loading.event = {}
Loading.tunnel = {}

function Loading:__construct()
    vRP.Extension.__construct(self)

    self.cfg = module("vrp_loading", "cfg/loading")
end 

function Loading.event:playerSpawn(user, first_spawn)
    if first_spawn and user:isReady() and self.cfg.multiCharacter then
        self.remote._close(user.source)
    end
end

vRP:registerExtension(Loading)