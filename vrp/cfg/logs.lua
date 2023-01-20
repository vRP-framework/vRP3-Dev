local cfg = {}

cfg.targetConfig = {
    ['database'] = "vrp_logs", -- table if selectedTarget is database
    ['file'] = 'logs', -- folder if selectedTarget is file
    ['print'] = 'print',
    ['discord'] = 'discord'
}

cfg.selectedTarget = 'file'

cfg.webhooks = {
    ['inventory'] = ''
}

cfg.destiny = {
    ['inventory-drop'] = {
        template = "[INVENTORY DROP]\nUSER: %d %s %s\nITEM: %s\nAMOUNT: %d\nLOCATION: %s",
        webhook = cfg.webhooks['inventory'] -- define if use discord.
    }
}


return cfg
