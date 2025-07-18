---TODO: Move it to server side
---Checks if you are admin
function IsAdmin()
    return true
end

---Check for permission
---@param permission string
function HasPermission(permission)
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