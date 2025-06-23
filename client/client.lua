local QBCore = exports['qb-core']:GetCoreObject()

local sellDistance = cfg.selldistance or 1.5
local sellCooldown = 30 
 local defaults = { progress_label = "Kauplete hinna üle...", sale_cancelled = "Katkestasid müügi."}
local nearPed = nil
local pedCoords = nil
local canSell = false
local selling = false
local sellItem = nil
local recentlySold = {}

local showingSellPrompt = false

local function StartPlayerEmote(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -8.0, duration, 49, 0, false, false, false)
end

local function ClearPlayerEmote()
    ClearPedTasks(PlayerPedId())
end

local function getLocale(key)
    local locale = cfg.locale or "et"
    if Locales[locale] and Locales[locale][key] then
        return Locales[locale][key]
    else 
        return defaults[key] or "Unknown translation"
    end
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
            for itemName, _ in pairs(cfg.selldrugs or {}) do
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
                        pedCoords = GetEntityCoords(nearPed)
                        DrawText3D(pedCoords + vector3(0, 0, 0.3), "[E] Müü")
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
                        showingSellPrompt = false

                        local pedNet = NetworkGetEntityIsNetworked(nearPed) and NetworkGetNetworkIdFromEntity(nearPed) or nil
                        FreezeEntityPosition(nearPed, true)
                        ClearPedTasks(nearPed)

                        StartPlayerEmote("misscarsteal4@actor", "actor_berating_loop", 3000)

                        QBCore.Functions.Progressbar("npc_sell", getLocale("progress_label"), 3000, false, true, {
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
                        end, function()
                            QBCore.Functions.Notify(getLocale("sale_cancelled"), "error")
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
            showingSellPrompt = false
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