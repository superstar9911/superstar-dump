Config = {}

-- Use qb-target (true) or E-key fallback (false)
Config.UseQbTarget = true

-- Time to search dumpster (ms)
Config.SearchTime = 5000

-- Dumpster cooldown (ms)
Config.DumpsterCooldown = 10 * 60 * 1000 -- 10 minutes

-- Base chance to find loot
Config.BaseFindChance = 0.9 -- 90%

-- Progressbar text
Config.ProgressText = "Digging through trash..."

-- Require specific item to search (optional)
Config.RequireItemToSearch = false
Config.SearchRequiredItem = "lockpick"

-- Only allow dumpster search at night (optional)
Config.OnlyNight = false
Config.NightStart = 22 -- 22:00
Config.NightEnd = 6    -- 06:00

-- Dumpster-specific loot tables
Config.Dumpsters = {
    ["prop_dumpster_01a"] = {
        label = "Green Dumpster",
        loot = {
            { item = "phone", weight = 0, min = 1, max = 3 },
            { item = "copper",     weight = 0, min = 1, max = 2 },
            { item = "steel",      weight = 0, min = 1, max = 1 },
        },
        rareLoot = {
            { item = "weapon_knife", amount = 1 },
        },
        rareChance = 0.02
    },
    ["prop_dumpster_02a"] = {
        label = "Blue Dumpster",
        loot = {
            { item = "plastic",  weight = 0, min = 2, max = 4 },
            { item = "rubber",   weight = 0, min = 1, max = 3 },
            { item = "glass",    weight = 0, min = 1, max = 2 },
        },
        rareLoot = {
            { item = "iron", amount = 2 },
        },
        rareChance = 0.01
    },
    ["prop_dumpster_03a"] = {
        label = "Black Dumpster",
        loot = {
            { item = "phone", weight = 0, min = 1, max = 3 },
            { item = "aluminum",   weight = 0, min = 1, max = 2 },
            { item = "copper",     weight = 0, min = 1, max = 2 },
        },
        rareLoot = {
            { item = "steel", amount = 1 },
        },
        rareChance = 0.015
    },
    ["prop_dumpster_4a"] = {
        label = "Rusty Dumpster",
        loot = {
            { item = "plastic",    weight = 0, min = 2, max = 5 },
            { item = "scrapmetal", weight = 0, min = 1, max = 3 },
            { item = "rubber",     weight = 0, min = 1, max = 2 },
        },
        rareLoot = {
            { item = "weapon_knife", amount = 1 },
        },
        rareChance = 0.01
    }
}

-- Notification helper
Config.Notify = function(source, msg, type)
    TriggerClientEvent('QBCore:Notify', source, msg, type or "success")
end
