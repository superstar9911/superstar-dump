local QBCore = exports['qb-core']:GetCoreObject()
local searchedDumpsters = {} -- local cooldowns

-- check if dumpster is cooling down
local function isDumpsterCooldown(netId)
    return searchedDumpsters[netId] and (GetGameTimer() - searchedDumpsters[netId] < Config.DumpsterCooldown)
end

-- search dumpster action
local function searchDumpster(entity)
    if not DoesEntityExist(entity) then return end

    -- make sure entity is networked
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if netId == 0 then
        NetworkRegisterEntityAsNetworked(entity)
        netId = NetworkGetNetworkIdFromEntity(entity)
        if netId == 0 then
            QBCore.Functions.Notify("Couldn’t network dumpster entity.", "error")
            return
        end
    end

    local model = GetEntityModel(entity)

    if isDumpsterCooldown(netId) then
        QBCore.Functions.Notify("This dumpster looks empty.", "error")
        return
    end

    if Config.RequireItemToSearch and not QBCore.Functions.HasItem(Config.SearchRequiredItem) then
        QBCore.Functions.Notify("You need " .. Config.SearchRequiredItem .. " to search.", "error")
        return
    end

    if Config.OnlyNight then
        local hour = GetClockHours()
        if (Config.NightStart > Config.NightEnd and not (hour >= Config.NightStart or hour < Config.NightEnd)) or
           (Config.NightStart < Config.NightEnd and not (hour >= Config.NightStart and hour < Config.NightEnd)) then
            QBCore.Functions.Notify("You can only search dumpsters at night.", "error")
            return
        end
    end

    QBCore.Functions.Progressbar("superstar_dump_search", Config.ProgressText, Config.SearchTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        local ped = PlayerPedId()
        TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
        Wait(2000)
        ClearPedTasks(ped)

        TriggerServerEvent("superstar-dump:server:searchDumpster", netId, model)
    end, function()
        QBCore.Functions.Notify("Canceled", "error")
    end)
end

-- qb-target setup
local function setupQbTarget()
    if not Config.UseQbTarget then return end
    for modelName, _ in pairs(Config.Dumpsters) do
        local modelHash = GetHashKey(modelName)
        exports['qb-target']:AddTargetModel({modelHash}, {
            options = {
                {
                    type = "client",
                    icon = "fas fa-trash",
                    label = "Search Dumpster",
                    action = function(entity)
                        local ent = entity
                        if type(entity) == "table" and entity.entity then ent = entity.entity end
                        if ent and DoesEntityExist(ent) then
                            searchDumpster(ent)
                        else
                            QBCore.Functions.Notify("Invalid dumpster.", "error")
                        end
                    end
                }
            },
            distance = 2.5
        })
    end
end

-- fallback E-key
local function keypressThread()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(5)
            if not Config.UseQbTarget and IsControlJustReleased(0, 38) then -- E
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local found = nil
                for modelName, _ in pairs(Config.Dumpsters) do
                    local hash = GetHashKey(modelName)
                    local handle, ent = FindFirstObject()
                    local success
                    repeat
                        if GetEntityModel(ent) == hash and #(pos - GetEntityCoords(ent)) <= 2.5 then
                            found = ent
                            break
                        end
                        success, ent = FindNextObject(handle)
                    until not success
                    EndFindObject(handle)
                    if found then break end
                end
                if found then
                    searchDumpster(found)
                else
                    QBCore.Functions.Notify("No dumpster nearby.", "error")
                end
            end
        end
    end)
end

-- receive cooldown from server
RegisterNetEvent('superstar-dump:client:setCooldown', function(netId)
    searchedDumpsters[netId] = GetGameTimer()
end)

-- init
Citizen.CreateThread(function()
    while not QBCore do Citizen.Wait(100) end
    Citizen.Wait(1000)
    if Config.UseQbTarget then setupQbTarget() end
    keypressThread()
end)
