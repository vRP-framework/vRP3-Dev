function Core.IsPlayerAdmin(source)
    if source == 0 or source == nil then return false end
    if IsPlayerAceAllowed(source, 'command') then
        return true
    end
    return false
end

LoadedSystems['admin'] = true