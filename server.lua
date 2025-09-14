local QBCore = exports['qb-core']:GetCoreObject()
local DumpsterCooldowns = {}

-- weighted loot picker
local function chooseLoot(lootTable)
    local total = 0
    for _, v in ipairs(lootTable) do total = total + (v.weight or 1) end
    local pick = math.random() * total
    local running = 0
    for _, v in ipairs(lootTable) do
        running = running + (v.weight or 1)
        if pick <= running then return v end
    end
    return lootTable[1]
end

-- cooldown checker
local function isOnCooldown(netId)
    local t = DumpsterCooldowns[netId]
    if not t then return false end
    return (os.time() * 1000) - t < Config.DumpsterCooldown
end

-- main dumpster search event
RegisterNetEvent('superstar-dump:server:searchDumpster', function(netId, model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- check dumpster model
    local chosenDumpster = nil
    for modelName, data in pairs(Config.Dumpsters) do
        if GetHashKey(modelName) == model then
            chosenDumpster = data
            break
        end
    end

    if not chosenDumpster then
        Config.Notify(src, "This dumpster can’t be searched.", "error")
        return
    end

    if isOnCooldown(netId) then
        Config.Notify(src, "This dumpster looks empty.", "error")
        TriggerClientEvent('superstar-dump:client:setCooldown', src, netId)
        return
    end

    if math.random() > Config.BaseFindChance then
        DumpsterCooldowns[netId] = os.time() * 1000
        Config.Notify(src, "You didn’t find anything this time.", "error")
        TriggerClientEvent('superstar-dump:client:setCooldown', src, netId)
        return
    end

    -- rare loot
    if chosenDumpster.rareLoot and math.random() < (chosenDumpster.rareChance or 0) then
        local rare = chosenDumpster.rareLoot[math.random(1, #chosenDumpster.rareLoot)]
        local ok = Player.Functions.AddItem(rare.item, rare.amount)
        if not ok then
            exports['qb-inventory']:AddItem(src, rare.item, rare.amount) -- force it in
        end
        Config.Notify(src, "You found rare: " .. rare.item, "success")
        DumpsterCooldowns[netId] = os.time() * 1000
        TriggerClientEvent('superstar-dump:client:setCooldown', src, netId)
        return
    end

    -- normal loot
    local loot = chooseLoot(chosenDumpster.loot)
    local amount = math.random(loot.min, loot.max)
    local ok = Player.Functions.AddItem(loot.item, amount)
    if not ok then
        exports['qb-inventory']:AddItem(src, loot.item, amount) -- force it in
    end
    Config.Notify(src, ("You found %d x %s"):format(amount, loot.item), "success")

    DumpsterCooldowns[netId] = os.time() * 1000
    TriggerClientEvent('superstar-dump:client:setCooldown', src, netId)
end)
