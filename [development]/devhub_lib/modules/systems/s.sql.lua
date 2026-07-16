Core.SQL = {}

-- EXECUTE (multiple rows affected)

-- Async Execute
Core.SQL.Execute = function(query, args, cb)
    MySQL.query(query, args, cb)
end

-- Sync Execute
Core.SQL.AwaitExecute = function(query, args)
    return MySQL.query.await(query, args)
end

-- SINGLE

-- Async Single
Core.SQL.Single = function(query, args, cb)
    MySQL.single(query, args, cb)
end

-- Sync Single
Core.SQL.AwaitSingle = function(query, args)
    return MySQL.single.await(query, args)
end

-- INSERT

-- Async Insert (returns insertId)
Core.SQL.Insert = function(query, args, cb)
    MySQL.insert(query, args, cb)
end

-- Sync Insert (returns insertId)
Core.SQL.AwaitInsert = function(query, args)
    return MySQL.insert.await(query, args)
end

-- UPDATE

-- Async Update
Core.SQL.Update = function(query, args, cb)
    MySQL.update(query, args, cb)
end

-- Sync Update (returns affectedRows)
Core.SQL.AwaitUpdate = function(query, args)
    return MySQL.update.await(query, args)
end

LoadedSystems['sql'] = true