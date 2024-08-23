-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
local init = module("vrp_menus", "cfg/components")
if not init.banking then return end

local lang = vRP.lang
local Banking = class("Banking", vRP.Component)

function Banking:__construct()
  vRP.Component.__construct(self)
	
	self.init = module("vrp_menus", "cfg/components")

  -- animations
  local function anim_enter(user)
    vRP.EXT.Base.remote._playAnim(user.source,false,{{"amb@prop_human_atm@male@enter","enter"},{"amb@prop_human_atm@male@idle_a","idle_a"}},false)
  end

  local function anim_exit(user)
    vRP.EXT.Base.remote._playAnim(user.source,false,{{"amb@prop_human_atm@male@exit","exit"}},false)
  end
  
  local function bank_deposit(menu)
    local user = menu.user
    local v = parseInt(user:prompt(lang.bank.deposit.prompt(),""))

    if v > 0 then
      if user:tryDeposit(v) then
        vRP.EXT.Base.remote._notify(user.source,lang.bank.deposit.deposited({v}))
        user:actualizeMenu()
      else
        vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  local function bank_withdraw(menu)
    local user = menu.user
    local v = parseInt(user:prompt(lang.bank.withdraw.prompt(),""))

    if v > 0 then
      if user:tryWithdraw(v) then
        vRP.EXT.Base.remote._notify(user.source,lang.bank.withdraw.withdrawn({v}))
        user:actualizeMenu()
      else
        vRP.EXT.Base.remote._notify(user.source,lang.bank.withdraw.not_enough())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end
  
  local function bank_transfer(menu)
    local user = menu.user
		local id = parseInt(user:prompt(lang.bank.transfer.user(),""))
		local v = parseInt(user:prompt(lang.bank.transfer.money(),""))
		local tuser = vRP.users[id]

    if tuser then
      user:tryWithdraw(v)
	  tuser:tryDeposit(v)
	  
	  vRP.EXT.Base.remote._notify(user.source,lang.bank.transfer.sent({v}))
	  vRP.EXT.Base.remote._notify(tuser.source,lang.bank.transfer.recieved({v}))
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end
	
	local function giveMoney()
		local user = menu.user
		local nuser
		local nplayer = vRP.EXT.Base.remote.getNearestPlayer(user.source,10)
		if nplayer then nuser = vRP.users_by_source[nplayer] end
		
		if nuser then
			-- prompt number
			local amount = parseInt(user:prompt(lang.money.give.prompt(),""))
			if amount > 0 and user:tryPayment(amount) then
				nuser:giveWallet(amount)
				vRP.EXT.Base.remote._notify(user.source,lang.money.given({amount}))
				vRP.EXT.Base.remote._notify(nuser.source,lang.money.received({amount}))
			else
				vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
			end
		else
			vRP.EXT.Base.remote._notify(user.source,lang.common.no_player_near())
		end
	end
  
  vRP.EXT.GUI:registerMenuBuilder("Bank", function(menu)
    menu.title = lang.bank.title()
    menu.css.header_color="rgba(0,255,125,0.75)"

    menu:addOption(lang.bank.info.title(), nil, lang.bank.info.bank({menu.user:getBank()}))
    menu:addOption(lang.bank.deposit.title(), bank_deposit, lang.bank.deposit.description())
    menu:addOption(lang.bank.withdraw.title(), bank_withdraw, lang.bank.withdraw.description())
		menu:addOption(lang.bank.transfer.title(), bank_transfer, lang.bank.transfer.description())
  end)
	
	--special
	vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
		menu:addOption(lang.money.give.title(), giveMoney, lang.money.give.description())
	end)
end

vRP:registerComponent(Banking)