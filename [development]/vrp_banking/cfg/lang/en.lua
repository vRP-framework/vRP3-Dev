
local lang = {
	main = {
		title = "{1}",
		veh = {
			error = "You cannot be in a Vehicle",
		},
		help_msg = "Press ~INPUT_FRONTEND_RB~ to access the ~b~{1} {2}~w~.",
	},
	error = {
		not_enough = "~r~Not enough money.",
		invalid_value = "~r~Invalid value.",
		whitelist = "~g~Banking privileges have been reinstated.",
		blacklist = "~r~Your banking privileges have been revoked and you can no longer access the banking system.",
	},
	atm = {
		deposit = "~g~${1} ~s~deposited.",
		withdraw = "~g~${1} ~s~withdrawn.",
		w_not_enough = "~r~You don't have enough money in your bank.",
		b_not_enough = "~r~You don't have enough money in your wallet.",
	},
	transfer = {
		error = "~r~You can't transfer money to yourself.",
		not_enough = "~r~You don't have enough money in your bank.",
		no_player = "~r~The player is not connected.",
		sent = "~g~you have sent ${1} to {2}",
		recieved = "~g~you got ${1} from {2}",
	},
	description = {
		default = "Bank transaction",
		deposit = "Cash Deposit",
		withdrawal = "Cash Withdrawal",
		transfer_sent = "Sent to {1}",
		transfer_received = "Gift from {1}",
		admin_add = "Gift from above",
		admin_remove = "Bank adjustment",
	},
}

return lang
