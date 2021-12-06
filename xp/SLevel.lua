Users = {}

RegisterNetEvent("Authentic:AddXP")
AddEventHandler("Authentic:AddXP", function(level)
    local source = source
    Users[source].xp = Users[source].xp + tonumber(level)
    TriggerClientEvent('::{AdastraRP}::esx:showNotification',source,"Vous avez gagner "..tonumber(level).." d'xp!")
    MySQL.Async.execute('UPDATE users SET xp=@xp WHERE identifier=@identifier', {
        ['@xp'] = Users[source].xp,
        ['@identifier'] = Users[source].identifier,
    })
end)

RegisterNetEvent("Authentic:SetXP")
AddEventHandler("Authentic:SetXP", function(ply,level)
    local source = source
    local rank = nil 
    local license = nil
    for _, foundID in ipairs(GetPlayerIdentifiers(source)) do
        if string.match(foundID, "license:") then
            license = foundID
            break
        end
    end
    MySQL.Async.fetchAll("SELECT permission_group FROM users WHERE identifier = @identifier", {["@identifier"] = license}, function(group)
        rank = group[1].permission_group
    end)
    while rank == nil do Wait(10) end
    if rank ~= "user" then
        Users[ply].xp = tonumber(level)
        TriggerClientEvent('::{AdastraRP}::esx:showNotification',ply,"Votre xp a été mit à "..level.." par "..GetPlayerName(source))
        TriggerClientEvent('Edit:xp', ply,level)
        MySQL.Async.execute('UPDATE users SET xp=@xp WHERE identifier=@identifier', {
            ['@xp'] = Users[ply].xp,
            ['@identifier'] = Users[ply].identifier,
        })
    else
        DropPlayer(source, 'nice try')
    end
end)

CreateThread(function()
    while true do 
        Wait(900000)
        for k,v in ipairs(Users) do
            AddXP(100,v.id,true)
        end
    end
end)

RegisterCommand('xp',function(source)
    local source = source
    AddXP(1,source,false)
end)

function AddXP(number,id,is)
    Users[id].xp = Users[id].xp + number
    if Users[id].xp >= 1584350 then Users[id].xp = 1584350 end
    TriggerClientEvent('Edit:xp',id,Users[id].xp)
    if is then
        TriggerClientEvent('::{AdastraRP}::esx:showNotification',id,"Vous avez gagner "..number.." d'xp !\nMerci de votre activité sur le serveur.")
    else
        TriggerClientEvent('::{AdastraRP}::esx:showNotification',id,"Vous avez reçu "..number.." d'xp !")
    end
    MySQL.Async.execute('UPDATE users SET xp=@xp WHERE identifier=@identifier', {
        ['@xp'] = Users[id].xp,
        ['@identifier'] = Users[id].identifier,
    })
end

AddEventHandler('playerDropped', function(reason)
    local source = source
    Users[source] = nil
end)

RegisterServerCallback('GetXPState', function(source, cb)
    if Users[source] == nil then
        local license = nil
        local discordid = nil
        local fivemid = nil
        for _, foundID in ipairs(GetPlayerIdentifiers(source)) do
            if string.match(foundID, "license:") then
                license = foundID
            elseif string.match(foundID, "discord:") then
                discordid = foundID
            elseif string.match(foundID, "fivem:") then
                fivemid = foundID
            end
        end
        Users[source] = {
            id = source,
            identifier = license,
            discord = discordid,
            fivem = fivemid
        } 
        MySQL.Async.fetchAll("SELECT xp FROM users WHERE identifier = @identifier", {["@identifier"] = license}, function(xp)
            cb(tonumber(xp[1].xp))
            Users[source].xp = tonumber(xp[1].xp)
        end)
    else
        cb(Users[source].xp)
    end
end)


RegisterServerCallback('GetXPStateFromPlayer', function(source, cb, id)
    if Users[id] ~= nil then
        cb(Users[id].xp,Users[id].discord,Users[id].fivem)
    end
end)