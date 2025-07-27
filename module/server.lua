local parties = {}
local votersData = {}

CreateThread(function()
    -- Load parties
    Wait(100)
    local LoadJson = json.decode(LoadResourceFile(GetCurrentResourceName(), '/db/parties.json'))
    if type(LoadJson) == 'table' then
        parties = LoadJson
    else
        SaveResourceFile(GetCurrentResourceName(), "/db/parties.json", '[]', -1)
        parties = {}
    end
    parties = LoadJson

    -- Load voters
    Wait(100)
    local LoadJson2 = json.decode(LoadResourceFile(GetCurrentResourceName(), '/db/voters.json'))
    if type(LoadJson2) == 'table' then
        votersData = LoadJson2
    else
        SaveResourceFile(GetCurrentResourceName(), "/db/voters.json", '[]', -1)
        votersData = {}
    end
    votersData = LoadJson2

    -- Set Values to statebag
    Wait(100)
    GlobalState.voting_status = GetResourceKvpInt('voting_status') == 1
    GlobalState.voting_permission = GetResourceKvpString('voting_permission')
end)

RegisterNetEvent("bs_voting:server:addParty", function(data)
    local src = source
    if not data.citizenId then Notification(src, "Invalid Citizen ID", "error") return end
    local name = GetCharacterName(data.citizenId)
    local partyData = { id = data.citizenId, name = name or '', party = data.partyName, logo = data.partyImage, votes = 0 }
    parties[data.citizenId] = partyData
    Notification(src, string.format('Added %s associated with %s', name, data.partyName), 'success')
    SaveResourceFile(GetCurrentResourceName(), "/db/parties.json", json.encode(parties,  { indent = true }), -1)
    CreateThread(function()
        OnEventTriggered('addParty', parties[data.citizenId])
    end)
end)

RegisterNetEvent("bs_voting:server:removeParty", function(data)
    if not data or not data.partyId then return end
    local partyData = parties[data.partyId]
    parties[data.partyId] = nil
    Notification(source, 'Removed successfully!', 'success')
    SaveResourceFile(GetCurrentResourceName(), "/db/parties.json", json.encode(parties,  { indent = true }), -1)
    CreateThread(function()
        OnEventTriggered('removeParty', partyData)
    end)
end)

RegisterNetEvent("bs_voting:server:addVotes", function(data)
    local source = source
    local citizenId = GetCharacterId(source)
    if not citizenId then return end
    if votersData[citizenId] then
        Notification(source, 'You have already casted your vote', 'error')
    else
        votersData[citizenId] = true
        parties[data.partyId].votes += 1
        Notification(source, 'You have casted your vote', 'success')
        SaveResourceFile(GetCurrentResourceName(), "/db/parties.json", json.encode(parties), -1)
        SaveResourceFile(GetCurrentResourceName(), "/db/voters.json", json.encode(votersData), -1)
        CreateThread(function()
            OnEventTriggered('addVotes', { voterSource = source, voterIdentifier = citizenId, partyId = data.partyId })
        end)
    end
end)

RegisterNetEvent("bs_voting:server:toggleVoting", function()
    local source = source
    local status = GetResourceKvpInt('voting_status') == 1
    SetResourceKvpInt('voting_status', status and 0 or 1)
    if status then
        Notification(source, "The voting has concluded.", "success", 15000)
    else
        Notification(source, "The voting has commenced.", "success", 15000)
    end
    GlobalState.voting_status = not status
    CreateThread(function()
        OnEventTriggered('toggleVoting', { votingStatus = GlobalState.voting_status })
    end)
end)

RegisterNetEvent("bs_voting:server:setPermission", function(data)
    local permission = data.permission or 'None'
    SetResourceKvp('voting_permission', permission)
    GlobalState.voting_permission = permission
    Notification(source, "Permission updated to "..permission, "success", 2000)
    CreateThread(function()
        OnEventTriggered('setPermission', { permission = GlobalState.voting_permission })
    end)
end)

RegisterNetEvent("bs_voting:server:clearData", function()
    parties = {}
    votersData = {}
    SaveResourceFile(GetCurrentResourceName(), "/db/parties.json", json.encode(parties,  { indent = true }), -1)
    SaveResourceFile(GetCurrentResourceName(), "/db/voters.json", json.encode(votersData), -1)
    Notification(source, 'All data has been wiped', 'success')
    CreateThread(function()
        OnEventTriggered('clearData', {})
    end)
end)

lib.callback.register("bs_voting:server:getParties", function(source)
    return parties
end)
