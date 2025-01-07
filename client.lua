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
        
        if aiming and IsPedShooting(playerPed) then
            if IsEntityAPed(entity) then
                local model = GetEntityModel(entity)
                print("Entity model:", model)
                if model == GetHashKey("a_c_cow") or model == GetHashKey("a_c_deer") then
                    print("Animal détecté !")
                    if IsEntityDead(entity) then
                        print("Animal tué !")
                        TriggerServerEvent('esx_hunting:animalDied', NetworkGetNetworkIdFromEntity(entity))
                    end
                end
            end
        end
    end
end)