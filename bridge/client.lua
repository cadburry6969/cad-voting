---@todo Move it to server side
---Checks if you are admin
function HasControlsPermission()
    return true
end

---Check for permission
---@param permission string
function HasPermission(permission)
    if GetResourceState('qbx_core') == 'started' then
        local playerData = exports.qbx_core:GetPlayerData()
        return playerData.job.name == permission
    elseif GetResourceState('qb-core') == 'started' then
        -- https://github.com/qbcore-framework/qb-core/commit/9adb33b970f16c92aaa2fe6d341ec23a716e0de6
        local playerData = exports['qb-core']:GetPlayerData()
        return playerData.job.name == permission
    elseif GetResourceState('es_extended') == 'started' then
        local ESX = exports.es_extended:getSharedObject()
        local playerData = ESX.GetPlayerData()
        return playerData.job.name == permission
    elseif GetResourceState('ox_core') == 'started' then
        local player = exports.ox_core:GetPlayer()
        return player.get('activeGroup') == permission
    end
    return true
end

---Notification
---@param message string
---@param type? string
---@param duration? number
function Notification(message, type, duration)
    if type == nil then type = 'inform' end
    lib.notify({ description = message, type = type, duration = duration })
end
