local chasseur = false

RegisterNetEvent("ch_chasse:prendrejob")
AddEventHandler("ch_chasse:prendrejob", function()
    chasseur = not chasseur
end)

AddEventHandler("onPlayerSpawn", function(playerId)
    chasseur = true
end)