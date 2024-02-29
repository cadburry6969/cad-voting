function SendNotify(msg, type, duration)
    duration = duration or 5000
    if Config.Notification == 'ox' then
        lib.notify({ description = msg, type = type or 'inform', duration = duration })
    elseif Config.Notification == 'qb' then
        TriggerEvent('QBCore:Notify', msg, type, duration)
    elseif Config.Notification == 'esx' then
        TriggerEvent('esx:showNotification', msg, type or 'info', duration)
    elseif Config.Notification == 'custom' then
        -- add your custom notification here
        print(msg, type, duration)
    end
end

function HasControlPanelAccess()
    return true
end

function HasPermission(permission)
    return true
end

function ShowText(msg)
    lib.showTextUI(msg)
end

function HideText()
    lib.hideTextUI()
end

RegisterNetEvent('cad-voting:client:playSound', function(sound, volume)
    SendNUIMessage({
        action = 'playSound',
        sound  = sound,
        volume = volume
    })
end)
