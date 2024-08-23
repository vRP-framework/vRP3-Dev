-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.money then return end

local lang = vRP.lang

-- Money module, wallet/bank
local Money = class("Money", vRP.Extension)

-- SUBCLASS

Money.User = class("User")

-- get wallet amount
function Money.User:getWallet()
  return self.cdata.wallet
end

-- get bank amount
function Money.User:getBank()
  return self.cdata.bank
end

-- set wallet amount
function Money.User:setWallet(amount)
  if self.cdata.wallet ~= amount then
    self.cdata.wallet = amount
    vRP:triggerEvent("playerMoneyUpdate", self)
  end
end

-- set bank amount
function Money.User:setBank(amount)
  if self.cdata.bank ~= amount then
    self.cdata.bank = amount
    vRP:triggerEvent("playerMoneyUpdate", self)
  end
end

-- give money to bank
function Money.User:giveBank(amount)
  self:setBank(self:getBank()+math.abs(amount))
end

-- give money to wallet
function Money.User:giveWallet(amount)
  self:setWallet(self:getWallet()+math.abs(amount))
end

-- try a payment (with wallet)
-- dry: if passed/true, will not affect
-- return true if debited or false
function Money.User:tryPayment(amount, dry)
  local money = self:getWallet()
  if amount >= 0 and money >= amount then
    if not dry then
      self:setWallet(money-amount)
    end
    return true
  else
    return false
  end
end

-- try a withdraw (from bank)
-- dry: if passed/true, will not affect
-- return true if withdrawn or false
function Money.User:tryWithdraw(amount, dry)
  local money = self:getBank()
  if amount >= 0 and money >= amount then
    if not dry then
      self:setBank(money-amount)
      self:giveWallet(amount)
    end
    return true
  else
    return false
  end
end

-- try a deposit
-- dry: if passed/true, will not affect
-- return true if deposited or false
function Money.User:tryDeposit(amount, dry)
  if self:tryPayment(amount, dry) then
    if not dry then
      self:giveBank(amount)
    end
    return true
  else
    return false
  end
end

-- try full payment (wallet + bank to complete payment)
-- dry: if passed/true, will not affect
-- return true if debited or false
function Money.User:tryFullPayment(amount, dry)
  local money = self:getWallet()
  if money >= amount then -- enough, simple payment
    return self:tryPayment(amount, dry)
  else  -- not enough, withdraw -> payment
    if self:tryWithdraw(amount-money, dry) then -- withdraw to complete amount
      return self:tryPayment(amount, dry)
    end
  end

  return false
end

-- METHODS

function Money:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/money")
end

-- EVENT
Money.event = {}

function Money.event:characterLoad(user)  -- init character money
  if not user.cdata.wallet then
    user.cdata.wallet = self.cfg.open_wallet
  end

  if not user.cdata.bank then
    user.cdata.bank = self.cfg.open_bank
  end

  vRP:triggerEvent("playerMoneyUpdate", user)
end

function Money.event:playerSpawn(user, first_spawn)	-- add money display
  if self.cfg.money_display and first_spawn then
    vRP.EXT.GUI.remote._setDiv(user.source,"money",self.cfg.display_css,lang.money.display({user:getWallet()}))
  end
end

function Money.event:playerDeath(user)
  if self.cfg.lose_wallet_on_death then
    user:setWallet(0)
  end
end

function Money.event:playerMoneyUpdate(user) -- update money dispaly
  if self.cfg.money_display then
	vRP.EXT.GUI.remote._setDivContent(user.source,"money",lang.money.display({user:getWallet()}))
  end
end

vRP:registerExtension(Money)
