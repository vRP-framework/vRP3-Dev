local lang = vRP.lang
local Luang = module("vrp", "lib/Luang")

local Banking = class("Banking", vRP.Extension)
Banking.event = {}
Banking.tunnel = {}

function Banking:__construct()
	vRP.Extension.__construct(self)
  
	self.cfg = module("vrp_banking", "cfg/cfg")
	self.allUsersData = {} -- table to hold all user info
	self.blockedUsers = {}  -- table to hold blocked users

	self.atms = {} -- table to hold atm locations
	-- Persist if DB is enabled
	if self.cfg.db then
		vRP:setGData("vRP:atm_locations", msgpack.pack(self.atms))
	end
	
	-- load lang
	self.luang = Luang()
	self.luang:loadLocale(vRP.cfg.lang, module("vrp_banking", "cfg/lang/"..vRP.cfg.lang))
	self.lang = self.luang.lang[vRP.cfg.lang]

	-- action handlers table (map action types to functions)
	self.actionHandlers = {
		withdrawal 		= self.withdraw,
		deposit    		= self.deposit,
		transfer   		= self.transfer,
		admin_add  		= self.admin,
		admin_remove 	= self.admin,
		admin_del 		= self.adminDel
	}

	-- Default descriptions by transaction type
	self.desc = {
		deposit           = self.lang.description.deposit(),
		withdrawal        = self.lang.description.withdrawal(),
		transfer_sent     = self.lang.description.transfer_sent({tostring(target)}),
		transfer_received = self.lang.description.transfer_received({tostring(target)}),
		admin_add         = self.lang.description.admin_add(),    		-- admin added money
		admin_remove      = self.lang.description.admin_remove()      -- admin removed money
	}

	-- will remove user from blocked list
	RegisterCommand("whitelist", function(source, args, rawCommand)
		for k,v in pairs(self.blockedUsers) do
			if args[1] and tonumber(args[1]) == tonumber(k) then

				self.blockedUsers[k] = nil

				for id, user in pairs(vRP.users) do
					self:broadcastContacts(user)

					if id == tonumber(k) then
						vRP.EXT.Base.remote._notify(user.source, self.lang.error.whitelist())
					end
				end
			end
		end
	end, false)	

	-- will remove user from blocked list
	RegisterCommand("blacklist", function(source, args, rawCommand)
		for id, users in pairs(vRP.users) do
			for k, v in pairs(self.allUsersData) do
				if tonumber(args[1]) == tonumber(v.user.accountId) then
					table.remove(self.allUsersData, k)

					self.blockedUsers[id] = true  -- add to block list

					for id, user in pairs(vRP.users) do
						self:broadcastContacts(users)

						if id == tonumber(k) then
							vRP.EXT.Base.remote._notify(user.source, self.lang.error.blacklist())

							self.remote._closeUI(user.source)
						end
					end
				end
			end
		end
	end, false)	
end

--**********************************
-- Functions
--**********************************
function Banking:registerMarker(user, list, markerCfg, prefix)
	local lang = self.lang.main

	local function enterATM(user, v)
		-- check if user is in vehicle (debug for no vehicle module)
		local inVeh = false

		if vRP.EXT.Vehicle and vRP.EXT.Vehicle.getVehicleUser then
			inVeh = vRP.EXT.Vehicle:getVehicleUser(user) or false
		end

		if inVeh then
			return vRP.EXT.Base.remote._notify(user.source, lang.veh.error())
		end

		if not self.blockedUsers[user.cid] then
			self.remote._openUI(user.source, "/atm", v)
		end
	end

	local function enterBank(user, v)
		if not self.blockedUsers[user.cid] then
			self.remote._openUI(user.source, "/bank", v)
		end
	end

	local function leave(user)
		self.remote._close(user.source)
	end

	-- Loop markers
	for k, v in pairs(list) do
		local name, gtype, x, y, z = table.unpack(v)
		local enterCallback =  enterBank

		if gtype == "Atm" then
			enterCallback =  enterATM
		end

		-- Clone marker config
		local ment = clone(markerCfg)
		ment[2].title = lang.title({gtype})
		ment[2].pos = {x, y, z - 1}

		-- Add entity
		vRP.EXT.Map.remote._addEntity(user.source, ment[1], ment[2])

		-- Register area
		user:setArea("vRP:" .. prefix .. ":" .. k,x,y,z,1,1.5, function(user) enterCallback(user, v) end, leave)
	end
end

-- Send updated contacts to all online users
function Banking:broadcastContacts(user)
	local contacts = self:getAllContacts(user)

	self.remote._updateContacts(user.source, contacts)
end

-- Generate contacts list for all users
function Banking:getAllContacts(user)
	self.allUsersData = {}
	local currentUser = user

	for id, user in pairs(vRP.users) do
		local bank = user.data.bank
		-- Skip blocked users
		if not self.blockedUsers[id] then
			-- Skip current user ONLY if debug mode is off
			if self.cfg.debug or user ~= currentUser then
				if bank then
					table.insert(self.allUsersData, {
						user = {
							name = {
								first = bank.user.name.first,
								last  = bank.user.name.last,
							},
							accountId = bank.accountId,
							phone = bank.phone,
							avatar = bank.avatar,
							isAdmin = bank.admin
						},
						balance = {
							bank = bank.balance,
							wallet = bank.wallet
						},
					})
				end
			end
		end
	end

	return self.allUsersData
end

function Banking:userInit(user)
	local data = user.data or {}
	user.data = data

	local bank = data.bank or {}
	data.bank = bank

	local identity = vRP.EXT.Identity:getIdentity(user.cid)
	local first, last = identity.firstname, identity.name

	-- User info
	bank.user = bank.user or {
		name = {
			first = first,
			last  = last
		}
	}

	-- Account ID
	if not bank.accountId then
		bank.accountId = string.format(
			"%0"..self.cfg.padValue.."d",
			self.cfg.startValue + user.cid
		)
	end

	-- Avatar
	if not bank.avatar then
		local avatars = self.cfg.default_avatar
		if avatars and #avatars > 0 then
			bank.avatar = avatars[math.random(#avatars)]
		end
	end

	-- Membership
	bank.membership = bank.membership or "Standard Member"

	-- Admin permission (direct assignment)
	bank.admin = user:hasPermission(self.cfg.admin_permission)

	-- Balances
	bank.balance = bank.balance or {
		bank = (bank.balance and bank.balance.bank) or user:getBank() or 0,
		wallet = (bank.balance and bank.balance.wallet) or user:getWallet() or 0
	}

	-- Transactions
	bank.transactions = bank.transactions or {}

	-- Phone
	bank.phone = identity.phone
end

function Banking:sendUserData(user)
	if not user or not user.data or not user.data.bank then return end
	local bank = user.data.bank

	-- Make sure the balance is always synced with the server-side bank
	bank.balance = user:getBank() or 0
	bank.wallet = user:getWallet() or 0

	local payload = {
		user = {
			name = {
				first = bank.user.name.first,
				last  = bank.user.name.last,
			},
			phone = bank.phone,
			avatar = bank.avatar,
			membership = bank.membership,
			["isAdmin"] = bank.admin
		},
		balance = {
			bank = bank.balance,
			wallet = bank.wallet,
		},
		transactions = bank.transactions or {}
	}

	self.remote._userData(user.source, payload) -- send to NUI
end

-- Add a transaction to the user's history
function Banking:addTransaction(user, txType, amount, target, description, icon)
	if not (user and user.data and user.data.bank) then return end

	local bank = user.data.bank
	bank.transactions = bank.transactions or {}

	-- Resolve description
	if not description then
		local template = self.lang.description[txType] or self.lang.description.default
		description = tostring(
			txType == "transfer_sent" or txType == "transfer_received"
		) and tostring(template):gsub("{1}", tostring(target or "")) or tostring(template)
	end

	-- Generate a transaction ID (monotonic, safer than #table)
	bank.lastTransactionId = (bank.lastTransactionId or 0) + 1
	local transactionId = bank.lastTransactionId

	-- Insert transaction at the start of the list
	table.insert(bank.transactions, 1, {
		id          = transactionId,
		type        = txType,
		amount      = amount,
		description = description,
		date        = os.date("%Y-%m-%d %H:%M:%S"),
		icon        = icon
	})

	-- Trim history if enabled
	if self.cfg.transactions.limit then
		local maxTx = self.cfg.transactions.max or 100
		while #bank.transactions > maxTx do
			table.remove(bank.transactions)
		end
	end
end

function Banking:validateAmount(user, amount, forWallet)
	amount = tonumber(amount)
	local balance = forWallet and user:getWallet() or user:getBank()

	if not amount or amount <= 0 or amount > balance then
		local msg = forWallet and self.lang.error.invalid_value() or self.lang.transfer.not_enough()
		vRP.EXT.Base.remote._notify(user.source, msg)
		return false, 0
	end

	return true, amount
end

--**********************************
-- Banking Actions 
--**********************************

function Banking:deposit(source, data)
	local user = vRP.users_by_source[source]
	if not user then return false end

	amount = tonumber(data.amount)
	local wallet = user:getWallet() -- cash in hand

	-- If amount is nil, not a number, or "all", deposit entire wallet
	if not amount or amount == "all" then
		amount = wallet
	else
		amount = tonumber(amount)
	end

	-- Validate amount against wallet (cash)
	local valid, amt = self:validateAmount(user, amount, true)
	if not valid then return false end

	-- Attempt deposit
	if user:tryPayment(amount) then
		--user:giveBank(amount)
		-- Add transaction
		self:addTransaction(user, "deposit", amount, nil)

		vRP.EXT.Base.remote._notify(source, self.lang.atm.deposit({amount}))
		self:sendUserData(user) -- push updated data to UI
		return true
	else
		vRP.EXT.Base.remote._notify(source, self.lang.atm.w_not_enough())
		return false
	end
end

function Banking:withdraw(source, data)
	local user = vRP.users_by_source[source]
	if not user then return false end

	amount = tonumber(data.amount)
	local bank_balance = user:getBank() -- current bank balance

	-- If amount is nil, not a number, or "all", withdraw entire balance
	if not amount or amount == "all" then
		amount = bank_balance
	else
		amount = tonumber(amount)
	end

	-- Validate amount against bank balance
	local valid, amt = self:validateAmount(user, amount)
	if not valid then return false end

	-- Attempt withdrawal
	
	if user:tryWithdraw(amt) then

		vRP.EXT.Base.remote._notify(user.source, self.lang.atm.withdraw({tostring(amt)}))

		-- Add transaction
		self:addTransaction(user, "withdrawal", amt, nil)

		self:sendUserData(user) -- push updated data to UI
		return true
	else
		vRP.EXT.Base.remote._notify(user.source, self.lang.atm.b_not_enough())
		return false
	end
end

function Banking:transfer(source, data)
	print("BANKING TRANSFER:", json.encode(data))
	local user = vRP.users_by_source[source]                 	-- sender
	local id = tonumber(data.contact.id)
	local target = vRP.users_by_cid[id]						-- recipient 
	local amount = tonumber(data.amount)

	-- Validation
	if not user or not target then return false end

	-- Blocked users cannot be transfer money
	if self.blockedUsers[target.cid] then return false end

	-- in debug mode, allow transfer to self
	if self.cfg.debug then target = user end

	-- Validate amount against sender's bank balance
	local valid, amt = self:validateAmount(user, amount)
	if not valid then print("Invalid amount for transfer") return false end

	-- Execute transfer	
	if not self.cfg.debug then
		user:tryWithdraw(amt) 					-- deduct from sender
		target:giveBank(amt)           	-- add to recipient		 		
	end

	-- Get names for notification messages
	local t_identity = vRP.EXT.Identity:getIdentity(target.cid)
	local u_identity = vRP.EXT.Identity:getIdentity(user.cid)
	local t_name = t_identity.firstname.." "..t_identity.name
	local u_name = u_identity.firstname.." "..u_identity.name

	-- Add transaction entries for both users
	self:addTransaction(user, "transfer_sent", amt, t_name) -- transaction sender
	self:addTransaction(target, "transfer_received", amt, u_name) -- transaction recipient

	-- Send notifications
	vRP.EXT.Base.remote._notify(source, self.lang.transfer.sent({amt, t_name}))
	vRP.EXT.Base.remote._notify(target.source, self.lang.transfer.recieved({amt, u_name}))

	-- Update both users' UIs
	self:sendUserData(user)        	-- sender
	self:sendUserData(target) 			-- recipient
	
	return true
end

--**********************************
-- Admin Functions
--**********************************

function Banking:admin_del(source, data)
	local userData = data.user
	if not userData then return false end

	local id = tonumber(userData.id)
	if not id then return false end

	for k, v in pairs(self.allUsersData) do
		if tonumber(v.user.accountId) == id then
			table.remove(self.allUsersData, k)

			self.blockedUsers[id] = true  -- add to block list

			for userId, allUsers in pairs(vRP.users) do
				self:broadcastContacts(allUsers)

				if userId == tonumber(k) then
					vRP.EXT.Base.remote._notify(allUsers.source, self.lang.error.blacklist())

					self.remote._closeUI(allUsers.source)
				end
			end

			return true
		end
	end

	return false
end

function Banking:adminRemoveFunds(target, amount)
	if target:tryFullPayment(amount) then return end

	target:setWallet(0)
	target:setBank(0)
end

function Banking:admin(source, data)
	local userData = data.user
	if not userData then return false end

	local id = tonumber(userData.id)
	local amount = tonumber(data.amount)
	local process = data.type

	-- Fast validation (cheapest checks first)
	if not id or not amount or amount <= 0 or not process then
		return false
	end

	local target = vRP.users_by_cid[id]
	if not target then return false end

	local notify = vRP.EXT.Base.remote._notify
	local description = data.description

	if process == "admin_remove" then
		self:adminRemoveFunds(target, amount)

		self:addTransaction(target, process, amount, nil, description)
		self:sendUserData(target)

		notify(target.source, self.lang.atm.withdraw({ amount }))
		return true
	end

	-- Deposit (no branching inside)
	target:giveBank(amount)

	self:addTransaction(target, process, amount, nil, description)
	self:sendUserData(target)

	notify(target.source, self.lang.atm.deposit({ amount }))

	return true
end

--**********************************
-- Event Handlers
--**********************************
function Banking.event:playerSpawn(user, first_spawn)
	if first_spawn then

		-- initialize user banking data
		self:userInit(user)

		-- register markers
		self:registerMarker(user, self.cfg.atms, self.cfg.marker.atm, "ATM")
    self:registerMarker(user, self.cfg.banks, self.cfg.marker.bank, "Bank")

		-- send user banking data to client
		self:sendUserData(user)

		-- update all users banking data
		self:broadcastContacts(user)
	end

	for id, allUsers in pairs(vRP.users) do
		self:broadcastContacts(allUsers)
	end
end

function Banking.event:playerLeave(user)
  for id, allUsers in pairs(vRP.users) do
		self:broadcastContacts(allUsers)
	end
end

--**********************************
-- tunnel functions
--**********************************

function Banking.tunnel:action(data)
	local user = vRP.users_by_source[source]
	if not user then return false end

	if data.type == "admin_del" then
		return self:admin_del(source, data) 
	end

	local handler = self.actionHandlers[data.type]
	if not handler then
		print("[BANKING] Invalid action:", json.encode(data))
		return false
	end

	return handler(self, user.source, data)
end

vRP:registerExtension(Banking)