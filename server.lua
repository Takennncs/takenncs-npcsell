local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('takenncs-npcsell:HasItem', function(source, cb, itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local item = Player.Functions.GetItemByName(itemName)
        cb(item and item.amount > 0)
    else
        cb(false)
    end
end)

RegisterNetEvent('takenncs-npcsell:sellItem', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local price = Config.SellItems[itemName]
    if Player and price then
        local item = Player.Functions.GetItemByName(itemName)
        if item and item.amount > 0 then
            Player.Functions.RemoveItem(itemName, 1)
            Player.Functions.AddMoney('cash', price, "npc-sell")
            TriggerClientEvent('QBCore:Notify', src, "Teenisid $" .. price, "success")
        else
            TriggerClientEvent('QBCore:Notify', src, "Sul pole müüdavat eset!", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "Eset ei saa müüa.", "error")
    end
end)

RegisterServerEvent('takenncs-npcsell:alertPolice', function(coords)
    local players = QBCore.Functions.GetPlayers()
    for _, playerId in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player and Player.PlayerData.job.name == "police" then
            TriggerClientEvent('QBCore:Notify', playerId, "Kahtlane tegevus", "error", 5000)
            TriggerClientEvent('takenncs-npcsell:policeAlertBlip', playerId, coords)
        end
    end
end)
