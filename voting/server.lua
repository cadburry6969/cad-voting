---#region Declares
local candidates = {}
local playersdata = {}
local settings = {}
---#endregion Declares

---#region Initiate Data
CreateThread(function()
    Wait(100)
    local json1 = json.decode(LoadResourceFile(GetCurrentResourceName(), 'data/candidates.json'))
    candidates = json1

    Wait(100)
    local json2 = json.decode(LoadResourceFile(GetCurrentResourceName(), 'data/players.json'))
    playersdata = json2

    Wait(100)
    local json3 = json.decode(LoadResourceFile(GetCurrentResourceName(), 'data/settings.json'))
    settings = json3

    GlobalState.votingCandidates = candidates
    GlobalState.votingStatus = settings.votingstatus
    GlobalState.votingPermission = settings.permission
end)
---#endregion Initiate Data

---#region EVENTS
RegisterNetEvent("cad-voting:server:setCandidate", function(pid, party, image)
    local src = source
    local cid = GetIdentifier(pid)
    local name = GetName(pid)
    if not cid or not name then return end
    local candidateData = { id = cid, name = name, party = party, logo = image, votes = 0 }
    candidates[cid] = candidateData
    SendNotify(src, string.format('Added %s associated with %s', name, party), 'success')
    SaveResourceFile(GetCurrentResourceName(), "data/candidates.json", json.encode(candidates, { indent = true }), -1)
    GlobalState.votingCandidates = candidates
end)

RegisterNetEvent("cad-voting:server:removeCandidate", function(cid)
    candidates[cid] = nil
    SendNotify(source, 'Removed successfully!', 'success')
    SaveResourceFile(GetCurrentResourceName(), "data/candidates.json", json.encode(candidates, { indent = true }), -1)
    GlobalState.votingCandidates = candidates
end)

RegisterNetEvent("cad-voting:server:addVotes", function(id)
    local cid = GetIdentifier(source)
    if not cid then
        SendNotify(source, 'Something went wrong', 'error')
        return
    end
    if playersdata[cid] then
        SendNotify(source, 'You cannot vote again', 'error')
    else
        playersdata[cid] = true
        candidates[id].votes = candidates[id].votes + 1
        PlaySound(source)
        SendNotify(source, 'You have casted your vote', 'success')
        SaveResourceFile(GetCurrentResourceName(), "data/candidates.json", json.encode(candidates, { indent = true }), -1)
        SaveResourceFile(GetCurrentResourceName(), "data/players.json", json.encode(playersdata, { indent = true }), -1)
    end
end)

RegisterNetEvent("cad-voting:server:toggleVoting", function()
    settings.votingstatus = not settings.votingstatus
    if settings.votingstatus then
        SendNotify(source, 'The voting has commenced.', 'success', 15000)
    else
        SendNotify(source, 'The voting has concluded.', 'success', 15000)
    end
    GlobalState.votingStatus = settings.votingstatus
    SaveResourceFile(GetCurrentResourceName(), "data/settings.json", json.encode(settings, { indent = true }), -1)
end)

RegisterNetEvent("cad-voting:server:setPermission", function(permission)
    settings.permission = permission
    GlobalState.votingPermission = settings.permission
    SendNotify(source, 'Permission Updated [' .. tostring(permission) .. '].', 2000)
    SaveResourceFile(GetCurrentResourceName(), "data/settings.json", json.encode(settings, { indent = true }), -1)
end)

RegisterNetEvent("cad-voting:server:clearAllData", function()
    candidates = {}
    playersdata = {}
    SaveResourceFile(GetCurrentResourceName(), "data/candidates.json", json.encode(candidates, { indent = true }), -1)
    SaveResourceFile(GetCurrentResourceName(), "data/players.json", json.encode(playersdata, { indent = true }), -1)
    SendNotify(source, 'All data has been wiped', 'success')
    GlobalState.votingCandidates = candidates
end)
---#endregion EVENTS
