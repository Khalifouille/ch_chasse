-- AJOUT DE DEUX ITEMS : VIANDE FRAICHE + VIANDE POURRIE (ox_inventory)
ESX = exports['es_extended']:getSharedObject()

local pedModel = "a_m_m_farmer_01"
local x, y, z = 966.145081, -2128.694580, 31.453491
local chasseur = false
local cooldown = 0

local playerPed = PlayerPedId()
local currentWeapon = GetSelectedPedWeapon(playerPed)

if currentWeapon ~= nil then
    print("Le joueur a tiré avec l'arme : " .. currentWeapon)
end

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

local animalPositions = {}
local markedEntities = {}

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
        
        if aiming and IsEntityAPed(entity) then
            local model = GetEntityModel(entity)
            local animalName = animalModels[model]

            if animalName then
                if IsEntityDead(entity) and not IsEntityMarked(entity) then
                    local animalPosition = GetEntityCoords(entity)
                    table.insert(animalPositions, animalPosition)
                    table.insert(markedEntities, entity)
                    -- print("Animal tué à la position : " .. animalPosition.x .. ", " .. animalPosition.y .. ", " .. animalPosition.z)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        for i, animalPosition in ipairs(animalPositions) do
            DrawMarker(1, animalPosition.x, animalPosition.y, animalPosition.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, nil, nil, false)
        end
    end
end)

function IsEntityMarked(entity)
    for i, markedEntity in ipairs(markedEntities) do
        if entity == markedEntity then
            return true
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 38) then
            local playerPed = PlayerPedId()
            local playerPosition = GetEntityCoords(playerPed)
            for i, animalPosition in ipairs(animalPositions) do
                if #(playerPosition - animalPosition) < 1.0 then
                    local currentWeapon = GetSelectedPedWeapon(playerPed)
                    print("Arme utilisée : " .. currentWeapon)
                    if GetSelectedPedWeapon(playerPed) == -1466123874 then
                        TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
                        Citizen.Wait(2000)
                        ClearPedTasksImmediately(playerPed)
                        TriggerServerEvent('ch_youness:donviande')
                    else
                        TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
                        Citizen.Wait(2000)
                        ClearPedTasksImmediately(playerPed)
                        TriggerServerEvent('ch_youness:donviande_pourrie')
                    end
                    RemoveAnimalMarker(i)
                    DeleteEntity(markedEntities[i])
                    table.remove(markedEntities, i)
                    break
                end
            end
        end
    end
end)

function RemoveAnimalMarker(index)
    table.remove(animalPositions, index)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i, animalPosition in ipairs(animalPositions) do
            local distance = #(vector3(animalPosition.x, animalPosition.y, animalPosition.z) - playerCoords)

            if distance <= 1.0 then
                if IsControlJustPressed(1, 38) then
                    local closestMarkerIndex = nil
                    local closestDistance = 1000.0
                    for j, markerPosition in ipairs(animalPositions) do
                        local markerDistance = #(vector3(markerPosition.x, markerPosition.y, markerPosition.z) - playerCoords)
                        if markerDistance < closestDistance then
                            closestMarkerIndex = j
                            closestDistance = markerDistance
                        end
                    end

                    if closestMarkerIndex ~= nil then
                        RemoveAnimalMarker(closestMarkerIndex)
                    end
                end
            end
        end
    end
end)
