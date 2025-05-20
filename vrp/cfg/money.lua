local cfg = {}

cfg.open_wallet = 5000  
cfg.open_bank = 10000

cfg.lose_wallet_on_death = true

cfg.money_display = true
cfg.money_delta = true

cfg.money_type = "USD"  -- Options: "USD", "EUR", "GBP", etc.

-- Add a mapping table for currency symbols:
cfg.currency_symbols = {
  USD = "$ ",
  EUR = "€ ",
  GBP = "£ "
}

cfg.display_css = [[
.div_money{
  position: absolute;
  background-color: rgba(0,0,0,0.4);
  top: 200px;
  right: 10px;
  text-align:center;
  padding: 5px;
  border-left: 6px solid #00a2d7;
  width : 170px;
  border-radius: 11px;
  font-size: 15px;
  font-weight: bold;
  font-family: cursive;
  color: #FFFFFF;
  text-shadow: 3px 3px 2px rgba(0, 0, 0, 0.80);
}
.div_money .symbol{
  font-size: 1.4em;
  color: #00ac51; 
}

.div_delta{
  position: absolute;
  right: 10px;
  top: 210px; /* same vertical base as .div_money */
  font-size: 1.2em;
  font-weight: bold;
  color: #00ff7f;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.8);
  z-index: 11000;
  animation: DeltaAnim 2s forwards;
}

@keyframes DeltaAnim {
  0%   { opacity: 0; transform: translateY(20px); }
  20%  { opacity: 1; transform: translateY(10px); }
  50%, 80% { opacity: 1; transform: translateY(0); }
  100% { opacity: 0; transform: translateY(-10px); }
}
]]

return cfg
