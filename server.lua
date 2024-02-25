QBCore = exports["qb-core"]:GetCoreObject()


--[[RegisterServerEvent('nwrp_checkin:PayForHeal')
AddEventHandler('nwrp_checkin:PayForHeal', function()
    local _source = source
    local Player = QBCore.Functions.GetPlayer(_source)
    --TriggerEvent("okokBilling:CreateCustomInvoice",  _source, 1000, 'Ošetření', 'Nemocnice', 'ambulance', 'ambulance')

end)]]--

QBCore.Functions.CreateCallback('nwrp_checkin:canpay', function(source, cb, args)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    local hasmoney = false

    if xPlayer.Functions.RemoveMoney('bank', 1000) then
        hasmoney = true
    elseif xPlayer.Functions.RemoveMoney('cash', 1000) then
        hasmoney = true
    end
    cb(hasmoney)
end)

RegisterServerEvent('nwrp_checkin:log')
AddEventHandler('nwrp_checkin:log' ,function(bedloc)
    local _source = source
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    local ped = GetPlayerPed(_source)
    local playerpos = GetEntityCoords(ped)
    local identif = exports['nwrp_core']:GetIdentifiers(_source)
    local distance = #(playerpos-bedloc)

    --print(distance)
    
    if distance > 30 then

        local Bname = 'Hráč se použil checkin na velkou vzdálenost'
        local Adminmessage

        Adminmessage = '**Hráč:** '..GetPlayerName(_source)..' || job: '..xPlayer.PlayerData.job.name..' ||'
        Adminmessage = Adminmessage..'\n\n**Pozice hráče:** '..playerpos
        Adminmessage = Adminmessage..'\n**Vzdálenost:** '..distance


        Adminmessage = Adminmessage..'\n\n**Hex-ID:** '..identif.steam
        Adminmessage = Adminmessage..'\n**License:** '..identif.license
        Adminmessage = Adminmessage..'\n**Discord ID:** '..identif.discord
        Adminmessage = Adminmessage..'\n**IP:** '..identif.ip
        Adminmessage = Adminmessage..'\n\n*Testovací verze*'

        TriggerEvent('nwrp_core:boxLog', Bname, Adminmessage, 'https://discord.com/api/webhooks/1126267446823768215/Y6bQMmeLwYVKDFl2MTzS9883n9pZr6mSmDrQXprIWO7xPR20CF2smbq2ShWhix_pMmhr', '3158326')
        
        DropPlayer(_source, 'Exploiting '..GetCurrentResourceName()..' - (too far): '..distance)
    else
        local Bname = 'Hráč se uzdravil v nemocnici'
        local Adminmessage

        Adminmessage = '**Hráč:** '..GetPlayerName(_source)..' || job: '..xPlayer.PlayerData.job.name..' ||'
        Adminmessage = Adminmessage..'\n\n**Pozice hráče:** '..playerpos
        Adminmessage = Adminmessage..'\n**Vzdálenost:** '..distance


        Adminmessage = Adminmessage..'\n\n**Hex-ID:** '..identif.steam
        Adminmessage = Adminmessage..'\n**License:** '..identif.license
        Adminmessage = Adminmessage..'\n**Discord ID:** '..identif.discord
        Adminmessage = Adminmessage..'\n**IP:** '..identif.ip
        Adminmessage = Adminmessage..'\n\n*Testovací verze*'

        TriggerEvent('nwrp_core:boxLog', Bname, Adminmessage, 'https://discord.com/api/webhooks/1126268056595865732/LsMAqf8_-rHLNpMjAMtBadsh202Th34-mVaHjYuNGtWrGe3ysI5TwjGiEzbmEZZ9xek9', '3158326')
        
        local message = 'Občan: **'..xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname..'** se nechal ošetřit'
        TriggerEvent('nwrp_core:boxLog', 'Doktor', message, 'https://discord.com/api/webhooks/1126268537468624906/Qnq0qWTta7jFyL1vUbOIDN2zd_Fp2doLlWFxhvGKIkYtCQioy9ArFJ-CLMK7wRsvZhLn', '3158326')

    end



end)