---Get character identifier (Ex: citizenid)
---@param playerId number
function GetCharacterId(playerId)
    if GetResourceState('qbx_core') == 'started' then
        local player = exports.qbx_core:GetPlayer(playerId)
        return player and player.PlayerData.citizenid
    elseif GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local player = QBCore.Functions.GetPlayer(playerId)
        return player and player.PlayerData.citizenid
    elseif GetResourceState('es_extended') == 'started' then
        local ESX = exports.es_extended:getSharedObject()
        local player = ESX.GetPlayerFromId(playerId)
        return player and player.getIdentifier()
    end
end

---Get character name
---@param identifier string
function GetCharacterName(identifier)
    if GetResourceState('qbx_core') == 'started' then
        local player = exports.qbx_core:GetPlayerByCitizenId(identifier) or exports.qbx_core:GetOfflinePlayer(identifier)
        return player and (player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname)
    elseif GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local player = QBCore.Functions.GetPlayerByCitizenId(identifier) or QBCore.Functions.GetOfflinePlayerByCitizenId(identifier)
        return player and (player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname)
    elseif GetResourceState('es_extended') == 'started' then
        local ESX = exports.es_extended:getSharedObject()
        local player = ESX.GetPlayerFromId(identifier)
        if not player then
            local result = MySQL.single.await('SELECT fullname, lastname FROM users WHERE identifier = ? LIMIT 1', { identifier })
            return result and (result.fullname .. ' ' .. result.lastname)
        end
        return player and player.getIdentifier()
    end
end

---Notification
---@param playerId number
---@param message string
---@param type? string
---@param duration? number
function Notification(playerId, message, type, duration)
    if type == nil then type = 'inform' end
    TriggerClientEvent("ox_lib:notify", playerId, { description = message, type = type, duration = duration })
end

---On Event Trigger
---@param eventName string
---@param data table<any>
function OnEventTriggered(eventName, data)
    if Config.Debug then print('[DEBUG] ', eventName, json.encode(data)) end
end