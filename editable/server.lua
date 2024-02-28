function SendNotify(src, msg, type, duration)
    duration = duration or 5000
    if Config.Notification == 'ox' then
        TriggerClientEvent("ox_lib:notify", src,
            { description = msg, type = type or 'inform', duration = duration })
    elseif Config.Notification == 'qb' then
        TriggerClientEvent('QBCore:Notify', src, msg, type, duration)
    elseif Config.Notification == 'esx' then
        TriggerClientEvent('esx:showNotification', src, msg, type or 'info', duration)
    elseif Config.Notification == 'custom' then
        -- add your custom notification here
        print(msg, type, duration)
    end
end

if Config.Framework == 'qb' then
    local QBCore = exports['qb-core']:GetCoreObject()

    function GetIdentifier(source)
        local player = QBCore.Functions.GetPlayer(source)
        if not player then return false end
        return player.PlayerData.citizenid
    end

    function GetName(source)
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.firstname
        else
            return GetPlayerName(source) or 'Unknown'
        end
    end
elseif Config.Framework == 'esx' then
    local ESX = exports['es_extended']:getSharedObject()

    function GetIdentifier(source)
        local player = ESX.GetPlayerFromId(source)
        if not player then return false end
        return player.getIdentifier()
    end

    function GetName(source)
        local player = ESX.GetPlayerFromId(source)
        return player.getName() or GetPlayerName(source) or 'Unknown'
    end
elseif Config.Framework == 'custom' then
    function GetIdentifier(source)
        return GetPlayerIdentifierByType(source, Config.Identifier)
    end

    function GetName(source)
        return GetPlayerName(source) or 'Unknown'
    end
end
