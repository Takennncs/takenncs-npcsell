local QBCore = exports['qb-core']:GetCoreObject()

local sellDistance = Config.SellDistance
local sellCooldown = 30 

local nearPed = nil
local pedCoords = nil
local canSell = false
local selling = false
local sellItem = nil
local recentlySold = {}

local lastSoldPedCoords = nil 
local showingSellPrompt = false

local function StartPlayerEmote(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -8.0, duration, 49, 0, false, false, false)
end

local function ClearPlayerEmote()
    ClearPedTasks(PlayerPedId())
end

Citizen.CreateThread(function()
    while true do
        Wait(500)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        nearPed, pedCoords, canSell, sellItem = nil, nil, false, nil

        for _, ped in ipairs(GetGamePool('CPed')) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsPedInAnyVehicle(ped, false) and not IsEntityDead(ped) then
                if not NetworkGetEntityIsNetworked(ped) then goto continue end

                local pedNet = NetworkGetNetworkIdFromEntity(ped)
                local dist = #(playerCoords - GetEntityCoords(ped))

                if dist < sellDistance and not recentlySold[pedNet] then
                    nearPed = ped
                    pedCoords = GetEntityCoords(ped)
                    break
                end
            end
            ::continue::
        end

        if nearPed and not selling then
            for itemName, _ in pairs(Config.SellItems) do
                QBCore.Functions.TriggerCallback('takenncs-npcsell:HasItem', function(hasItem)
                    if hasItem and not selling then
                        canSell = true
                        sellItem = itemName
                    end
                end, itemName)

                Wait(100)
                if canSell then break end
            end

            if canSell then
                showingSellPrompt = true
                while nearPed and canSell do
                    Wait(0)
                    if nearPed and not IsEntityDead(nearPed) then
                        DrawText3D(pedCoords + vector3(0, 0, 1.0), "[E] Müü")
                    else
                        canSell, sellItem = false, nil
                        showingSellPrompt = false
                        break
                    end

                    if #(GetEntityCoords(PlayerPedId()) - pedCoords) > sellDistance then
                        canSell, sellItem = false, nil
                        showingSellPrompt = false
                        break
                    end

                    if IsControlJustReleased(0, 38) then 
                        selling = true
                        canSell = false

                        local pedNet = NetworkGetEntityIsNetworked(nearPed) and NetworkGetNetworkIdFromEntity(nearPed) or nil
                        FreezeEntityPosition(nearPed, true)
                        ClearPedTasks(nearPed)

                        StartPlayerEmote("misscarsteal4@actor", "actor_berating_loop", 3000)

                        QBCore.Functions.Progressbar("npc_sell", "Kauplete hinna üle...", 3000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {}, {}, {}, function()
                            ClearPlayerEmote()
                            StartPlayerEmote("mp_common", "givetake1_a", 1200)
                            TriggerServerEvent('takenncs-npcsell:sellItem', sellItem)

                            if pedNet then
                                recentlySold[pedNet] = true
                            end

                            ClearPedTasksImmediately(nearPed)
                            FreezeEntityPosition(nearPed, false)
                            TaskStartScenarioInPlace(nearPed, "WORLD_HUMAN_SMOKING", 0, true)

                            SetTimeout(1200, function()
                                ClearPedTasks(nearPed)
                                TaskWanderStandard(nearPed, 10.0, 10)
                            end)

                            selling = false
                            lastSoldPedCoords = pedCoords 
                        end, function()
                            QBCore.Functions.Notify("Katkestasid müügi.", "error")
                            ClearPlayerEmote()
                            FreezeEntityPosition(nearPed, false)
                            selling = false
                        end)

                        break
                    end
                end
            else
                showingSellPrompt = false
            end
        else
            if lastSoldPedCoords and not showingSellPrompt then
                local pedAtCoords = nil
                for _, ped in ipairs(GetGamePool('CPed')) do
                    if #(GetEntityCoords(ped) - lastSoldPedCoords) < 1.0 and not IsEntityDead(ped) then
                        pedAtCoords = ped
                        break
                    end
                end

                if pedAtCoords and #(playerCoords - lastSoldPedCoords) <= sellDistance then
                    DrawText3D(lastSoldPedCoords + vector3(0, 0, 1.0), "[E] Müü")
                else
                    lastSoldPedCoords = nil
                end
            end
        end
    end
end)

function DrawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = string.len(text) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end
