---#region Declares
local inVotingScreen = false
local inVotingBooth = false
---#endregion Declares

---#region FUNCTIONS
local function openUI()
    if inVotingScreen then return end
    local response = lib.callback.await("voting:server:getParties", false)
    if not next(response) then
        Notification("No candidates", "error")
        return
    end
    inVotingScreen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "showUI",
        data = {
            settings = Config.UI,
            parties = response
        }
    })
end

local function closeUI()
    if not inVotingScreen then return end
    inVotingScreen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeUI",
    })
end

local function toggleVoting()
    if GlobalState.voting_status then
        if inVotingScreen then
            closeUI()
        else
            openUI()
        end
    else
        Notification('Voting has been concluded', 'error')
    end
end

local function addParty()
    local input = lib.inputDialog("Set Candidate Information", {
        { type = 'input', label = 'Character ID', required = true },
        { type = 'input', label = 'Candidate Party Name',   required = true },
        { type = 'input', label = 'Candidate Party Image',  required = true },
    }) or {}
    if input then
        if not input[1] or not input[2] or not input[3] then return end
        TriggerServerEvent("voting:server:addParty",
            { citizenId = input[1], partyName = input[2], partyImage = input[3] })
    end
end
---#endregion FUNCTIONS

---#region NUICALLBACKS
RegisterNUICallback('castVote', function(data, cb)
    TriggerServerEvent('voting:server:addVotes', { partyId = data.partyId })
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    closeUI()
    cb('ok')
end)
---#endregion NUICALLBACKS

---#region EVENTS
RegisterNetEvent("voting:client:openVotingMenu", function()
    local options = {
        {
            title = "Add New Candidate",
            onSelect = function(args)
                addParty()
            end,
        },
        {
            title = "Check Candidates",
            onSelect = function(args)
                TriggerServerEvent('voting:server:viewParties')
            end,
        }
    }
    lib.registerContext({
        id = 'voting_admin',
        title = 'Candidate Information',
        options = options
    })
    lib.showContext("voting_admin")
end)

RegisterNetEvent("voting:client:showResults", function(parties)
    local options = {}
    if parties and next(parties) then
        for _, data in pairs(parties) do
            options[#options + 1] = {
                title = string.format('%s', data.name),
                description = string.format('%s : %d', data.party, data.votes or 0),
                image = data.logo
            }
        end
    else
        options[#options + 1] = {
            title = 'No votes assigned to parties'
        }
    end
    lib.registerContext({
        id = 'voting_results',
        title = 'Voting Results',
        options = options
    })
    lib.showContext("voting_results")
end)

RegisterNetEvent("voting:client:showParties", function(parties)
    local options = {
        {
            title = 'Select to remove the candiate',
            description = '(Voting should be concluded before removing candidate)'
        }
    }
    for _, data in pairs(parties) do
        options[#options + 1] = {
            title = string.format('%s', data.party),
            description = string.format('%s : %s', data.id, data.name),
            image = data.logo,
            disabled = GlobalState.voting_status,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Remove Candidate',
                    content = string.format('Are you sure you want to remove %s associated with %s ?', data.name,
                        data.party),
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('voting:server:removeParty', { partyId = data.id })
                end
            end
        }
    end
    lib.registerContext({
        id = 'voting_candidates',
        title = 'Voting Candidates',
        options = options
    })
    lib.showContext("voting_candidates")
end)

RegisterNetEvent("voting:client:clearData", function(source)
    local alert = lib.alertDialog({
        header = 'Clear Voting Data',
        content =
        'Are you sure you want to clear voting data? \n\n This will remove all players vote status, all candidates and party votes !!',
        centered = true,
        cancel = true
    })
    if alert == 'confirm' then
        TriggerServerEvent('voting:server:clearData')
    end
end)
---#endregion EVENTS

---#region KEYBINDS
lib.addKeybind({
    name = 'voting',
    description = 'Access Voting Booth',
    defaultKey = 'E',
    onPressed = function(self)
        if inVotingBooth then
            if GlobalState.voting_permission ~= 'None' then
                local hasPerm = HasPermission(GlobalState.voting_permission)
                if not hasPerm then return Notification('You dont have permission') end
                toggleVoting()
            else
                toggleVoting()
            end
        end
    end
})
---#endregion KEYBINDS

---#region INITDATA
CreateThread(function()
    for _, data in pairs(Config.VotingBooths) do
        lib.zones.box({
            coords = data.coords,
            size = data.size,
            rotation = data.rotation,
            debug = Config.Debug,
            onEnter = function()
                if GlobalState.voting_status then
                    lib.showTextUI('[E] Voting Booth')
                    inVotingBooth = true
                else
                    lib.showTextUI('Booth Closed')
                end
            end,
            onExit = function()
                lib.hideTextUI()
                inVotingBooth = false
            end
        })
    end
    for _, data in pairs(Config.ControlPanels) do
        exports.ox_target:addBoxZone({
            coords = data.coords,
            size = data.size,
            rotation = data.rotation,
            debug = Config.Debug,
            options = {
                {
                    label = 'Commence/Conclude',
                    icon = 'fa-solid fa-person-booth',
                    canInteract = function()
                        return IsAdmin()
                    end,
                    onSelect = function()
                        local alert = lib.alertDialog({
                            header = 'Commence / Conclude Voting',
                            content = 'Are you sure you want to change voting state?',
                            centered = true,
                            cancel = true
                        })
                        if alert == 'confirm' then
                            TriggerServerEvent("voting:server:toggleVoting")
                        end
                    end
                },
                {
                    label = 'Change Permission',
                    icon = 'fa-solid fa-person-booth',
                    canInteract = function()
                        return IsAdmin()
                    end,
                    onSelect = function()
                        local input = lib.inputDialog('Permission', {
                            { type = 'input', label = 'Name', description = 'Example: police' },
                        })
                        if input and input[1] then
                            if input[1] == '' then input[1] = 'None' end
                            TriggerServerEvent("voting:server:setPermission", { permission = input[1] })
                        end
                    end
                },
                {
                    label = 'Clear Permission',
                    icon = 'fa-solid fa-person-booth',
                    canInteract = function()
                        return IsAdmin()
                    end,
                    onSelect = function()
                        TriggerServerEvent("voting:server:setPermission", { permission = false })
                    end
                },
                {
                    label = 'Candidates Information',
                    icon = 'fa-solid fa-person-booth',
                    canInteract = function()
                        return IsAdmin()
                    end,
                    onSelect = function()
                        TriggerEvent("voting:client:openVotingMenu")
                    end
                },
                {
                    label = 'View Results',
                    icon = 'fa-solid fa-person-booth',
                    canInteract = function()
                        return IsAdmin()
                    end,
                    onSelect = function()
                        TriggerServerEvent("voting:server:viewResults")
                    end
                },
            }
        })
    end
end)
---#endregion INITDATA
