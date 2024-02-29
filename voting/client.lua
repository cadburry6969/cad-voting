---#region Declares
local isUIOpen = false
---#endregion Declares

---#region FUNCTIONS
local function openUI()
    if isUIOpen then return end
    local candidateData = GlobalState.votingCandidates
    if not next(candidateData) then
        SendNotify("No candidates", "error")
        return
    end
    isUIOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "showUI",
        data = candidateData
    })
end

local function closeUI()
    if not isUIOpen then return end
    isUIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeUI",
    })
end

local function openVoting()
    if GlobalState.votingStatus then
        if isUIOpen then
            closeUI()
        else
            openUI()
        end
    else
        SendNotify('Voting has been concluded', 'error')
    end
end

local function addCandidate()
    if GlobalState.votingStatus then
        SendNotify("Conclude voting to add candidates", "error")
        return
    end
    local input = lib.inputDialog("Set Candidate Information", {
        { type = 'number', label = 'Candidate Server Id',  step = 1,       min = 1, required = true },
        { type = 'input',  label = 'Candidate Party Name', required = true },
        { type = 'input',  label = 'Candidate Image',      required = true },
    }) or {}
    if input then
        if not input[1] or not input[2] or not input[3] then return end
        TriggerServerEvent("cad-voting:server:setCandidate", input[1], input[2], input[3])
    end
end

local function viewResults()
    local options = {}
    local parties = GlobalState.votingCandidates
    if next(parties) then
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
end

local function clearVotingData()
    if GlobalState.votingStatus then
        SendNotify('Conclude voting before you clear data')
        return
    end
    local alert = lib.alertDialog({
        header = 'Clear Voting Data',
        content =
        'Are you sure you want to clear voting data? \n\n This will remove all players vote status, all candidates and party votes !!',
        centered = true,
        cancel = true
    })
    if alert == 'confirm' then
        TriggerServerEvent('cad-voting:server:clearAllData')
    end
end

local function showCandidates()
    local options = {}
    local parties = GlobalState.votingCandidates
    if parties and next(parties) then
        for _, data in pairs(parties) do
            options[#options + 1] = {
                title = string.format('%s', data.party),
                description = string.format('%s (%s)', data.name, data.id),
                image = data.logo,
                disabled = GlobalState.votingStatus,
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'Remove Candidate',
                        content = string.format('Are you sure you want to remove %s associated with %s ?', data.name,
                            data.party),
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then
                        TriggerServerEvent('cad-voting:server:removeCandidate', data.id)
                    end
                end
            }
        end
    else
        options[#options + 1] = {
            title = 'There are no candidates'
        }
    end
    lib.registerContext({
        id = 'voting_candidates',
        title = 'Voting Candidates',
        options = options
    })
    lib.showContext("voting_candidates")
end

local function candidateInformation()
    local options = {
        {
            title = "Add Candidate",
            onSelect = function(args)
                addCandidate()
            end,
        },
        {
            title = "View Candidates",
            onSelect = function(args)
                showCandidates()
            end,
        }
    }
    lib.registerContext({
        id = 'voting_admin',
        title = 'Candidate Information',
        options = options
    })
    lib.showContext("voting_admin")
end

-- local function changePermission()
--     local input = lib.inputDialog('Permission Box', {
--         { type = 'checkbox', label = 'Check Permission' },
--         { type = 'input',    label = 'Permission',      description = 'Name (eg: police)' },
--     })
--     if input[1] and input[2] then
--         TriggerServerEvent("cad-voting:server:setPermission", input[2])
--     else
--         TriggerServerEvent("cad-voting:server:setPermission", false)
--     end
-- end

local function toggleVoting()
    local alert = lib.alertDialog({
        header = GlobalState.votingStatus and 'Conclude Voting' or 'Commence Voting',
        content = 'Are you sure you want to change voting state?',
        centered = true,
        cancel = true
    })
    if alert == 'confirm' then
        TriggerServerEvent("cad-voting:server:toggleVoting")
    end
end

local function controlPanel()
    if not HasControlPanelAccess() then
        SendNotify('You cannot access control panel')
        return
    end
    local options = {
        {
            title = 'Commence/Conclude',
            onSelect = function()
                toggleVoting()
            end
        },
        -- {
        --     title = 'Change Permission',
        --     onSelect = function()
        --         changePermission()
        --     end
        -- },
        {
            title = 'Candidates Information',
            onSelect = function()
                candidateInformation()
            end
        },
        {
            title = 'View Results',
            onSelect = function()
                viewResults()
            end
        },
        {
            title = 'Clear Voting Data',
            onSelect = function()
                clearVotingData()
            end
        },
    }
    lib.registerContext({
        id = 'voting_controlpanel',
        title = 'Voting Control Panel',
        options = options
    })
    lib.showContext("voting_controlpanel")
end

local function openBooth()
    -- if GlobalState.votingPermission then
    --     local hasPerm = HasPermission(GlobalState.votingPermission)
    --     if not hasPerm then
    --         SendNotify('You are not allowed to cast a vote')
    --         return
    --     end
    -- end
    openVoting()
end
---#endregion FUNCTIONS

---#region NUICALLBACKS
RegisterNUICallback('submit', function(data, cb)
    TriggerServerEvent('cad-voting:server:addVotes', data.id)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    closeUI()
    cb('ok')
end)
---#endregion NUICALLBACKS

---#region INITDATA
CreateThread(function()
    local zone = Config.Zones
    for _, data in pairs(zone.Booths) do
        local point = lib.points.new({
            coords = data.coords,
            distance = data.distance,
        })

        function point:onEnter()
            local text = GlobalState.votingStatus and '[E] Voting Booth' or 'Booth Closed'
            ShowText(text)
        end

        function point:onExit()
            HideText()
        end

        function point:nearby()
            if IsControlJustReleased(0, 38) then
                openBooth()
            end
        end
    end
    for _, data in pairs(zone.ControlPanels) do
        local point = lib.points.new({
            coords = data.coords,
            distance = data.distance,
        })

        function point:onEnter()
            ShowText('[E] Voting Control Panel')
        end

        function point:onExit()
            HideText()
        end

        function point:nearby()
            if IsControlJustReleased(0, 38) then
                controlPanel()
            end
        end
    end
end)
---#endregion INITDATA
