-- AJOUT DE DEUX ITEMS : VIANDE FRAICHE + VIANDE POURRIE (ox_inventory)
ESX = exports['es_extended']:getSharedObject()

local pedModel = "a_m_m_farmer_01"
local x, y, z = 966.145081, -2128.694580, 31.453491
local chasseur = false

Citizen.CreateThread(function()
    RequestModel(GetHashKey(pedModel))
    while not HasModelLoaded(GetHashKey(pedModel)) do
        Citizen.Wait(1)
    end

    local ped = CreatePed(4, GetHashKey(pedModel), x, y, z - 1.0, 0.0, true, true)
    if not DoesEntityExist(ped) then
        return
    end

    FreezeEntityPosition(ped, true)
    if not NetworkGetEntityIsNetworked(ped) then
        NetworkRegisterEntityAsNetworked(ped)
    end

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(vector3(x, y, z) - playerCoords)

            if distance <= 2.0 then
                if IsControlJustPressed(1, 38) then
                    local playerInventory = ESX.GetPlayerData().inventory
                    local hasKnife = false
                    for i, item in pairs(playerInventory) do
                        if item.name == "WEAPON_KNIFE" then
                            hasKnife = true
                            break
                        end
                    end

                    if not hasKnife then
                        TriggerEvent("chat:addMessage", {
                            color = { 255, 0, 0},
                            multiline = true,
                            args = {"Employeur : ", "Va t'équiper sale nouille et reviens me voir"}
                        })
                    else
                        chasseur = not chasseur
                        TriggerServerEvent("ch_chasse:prendrejob")
                        if chasseur then
                            TriggerEvent("chat:addMessage", {
                                color = { 255, 0, 0},
                                multiline = true,
                                args = {"Employeur : ", "Bienvenue dans le job Chasseur"}
                            })
                        else
                            TriggerEvent("chat:addMessage", {
                                color = { 255, 0, 0},
                                multiline = true,
                                args = {"Employeur : ", "Tu as quitter le job, my biche"}
                            })
                        end
                    end
                end
            end
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local aiming, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
        local animalModels = {
            [-50684386] = "Vache",
            [-541762431] = "Lapin",
            [-664053099] = "Cerf",
            [-1323586730] = "Halouf",
            [-832573324] = "Sanglier",
        }
        
        if aiming and IsPedShooting(playerPed) then
            if IsEntityAPed(entity) then
                local model = GetEntityModel(entity)
                local animalName = animalModels[model]

                if animalName then
                    if IsEntityDead(entity) then
                        local animalPosition = GetEntityCoords(entity)
                        print("Animal mort:", animalName, "Position:", animalPosition)
                        TriggerServerEvent('esx_hunting:animalDied', NetworkGetNetworkIdFromEntity(entity), animalName, animalPosition)
                        local marker = DrawMarker(1, animalPosition.x, animalPosition.y, animalPosition.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, nil, nil, false)
                    end
                else
                    print("Modèle d'animal inconnu:", model)
                end
            else
                print("L'entité n'est pas un ped:", entity)
            end
        end
    end
end)
