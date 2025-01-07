ESX = exports['es_extended']:getSharedObject()

local chasseur = false

RegisterNetEvent("ch_chasse:prendrejob")
AddEventHandler("ch_chasse:prendrejob", function()
    chasseur = not chasseur
end)

AddEventHandler("onPlayerSpawn", function(playerId)
    chasseur = false
end)

RegisterServerEvent('esx_hunting:animalDied')
AddEventHandler('esx_hunting:animalDied', function(animalNetId)
    print("Animal mort détecté, NetID:", animalNetId)
    TriggerClientEvent('esx_hunting:animalKilled', -1, NetworkGetEntityFromNetworkId(animalNetId))
end)

