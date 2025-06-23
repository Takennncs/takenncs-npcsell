local QBCore = exports['qb-core']:GetCoreObject()
local defaults = { sale_success = "Teenisid $%s",no_item = "Sul pole müüdavat eset!", cannot_sell = "Eset ei saa müüa.", police_alert = "Kahtlane tegevus"}
QBCore.Functions.CreateCallback('takenncs-npcsell:HasItem', function(source, cb, itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local item = Player.Functions.GetItemByName(itemName)
        cb(item and item.amount > 0)
    else
        cb(false)
    end
end)
local function getLocale(key)
    local locale = cfg.locale or "en"
    if Locales[locale] and Locales[locale][key] then
        return Locales[locale][key]
    else
        return defaults[key] or "Unknown translation"
    end
end

RegisterNetEvent('takenncs-npcsell:sellItem', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local price = cfg.selldrugs[itemName]
    if Player and price then
        local item = Player.Functions.GetItemByName(itemName)
        if item and item.amount > 0 then
            Player.Functions.RemoveItem(itemName, 1)
            Player.Functions.AddMoney('cash', price, "npc-sell")
            TriggerClientEvent('QBCore:Notify', src, getLocale("sale_success"):format(price), "success")
        else
            TriggerClientEvent('QBCore:Notify', src, getLocale("no_item"), "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, getLocale("cannot_sell"), "error")
    end
end)

RegisterServerEvent('takenncs-npcsell:alertPolice', function(coords)
    local players = QBCore.Functions.GetPlayers()
    for _, playerId in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player and Player.PlayerData.job.name == "police" then
            TriggerClientEvent('QBCore:Notify', playerId, getLocale("police_alert"), "error", 5000)
            TriggerClientEvent('takenncs-npcsell:policeAlertBlip', playerId, coords)
        end
    end
end)