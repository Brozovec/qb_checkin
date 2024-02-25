QBCore = exports["qb-core"]:GetCoreObject()
local isOnBed = false
local doctorPed
local currentBedCoords
local hasLeft = true
local shouldDrawMarker = false
local markerCoords
local source = GetClosestPlayer
local Player = {}


function GetFreeBed()
    local closestBed = nil
    local found = false

    for k, v in pairs(Config.Beds) do
        local cPlayer, cDist = QBCore.Functions.GetClosestPlayer(v.Loc)
        if cPlayer == -1 or cDist > 1.5 then
            found = true
            isOnBed = true
            closestBed = v
            break
        end
    end

    if not found then
        exports['okokNotify']:Alert('Nemocnice', 'Všechny postele jsou obsazeny', Time, 'red')
            return closestBed
    end

    return closestBed

end

function GetOnTheBed(bed)
    local ped = PlayerPedId()

    SetEntityCoords(ped, bed.Loc + bed.OffSet)
    SetEntityHeading(ped, bed.Heading)
    currentBedCoords = bed.Loc
    hasLeft = false

    RequestAnimDict('anim@gangops@morgue@table@')
    while not HasAnimDictLoaded('anim@gangops@morgue@table@') do
        Wait(10)
    end



    TaskPlayAnim(ped, 'anim@gangops@morgue@table@', 'ko_front', 8.0, -8.0, -1, 1, 0, false, false, false)
  
    --45000
    QBCore.Functions.Progressbar("task", "Probíhá ošetření", 1000, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
      }, {
      }, {}, {}, function() -- Done
        if not hasLeft and currentBedCoords and isOnBed then
            SetEntityHealth(PlayerPedId(), 50000)
        --    TriggerServerEvent('nwrp_checkin:PayForHeal')
            --Player = QBCore.Functions.GetPlayerData()
            --print('src: '..Player.source)
            --TriggerServerEvent("okokBilling:CreateCustomInvoice",  Player.source, 1000, 'Ošetření', 'Nemocnice', 'ambulance', 'ambulance')
            TriggerServerEvent('nwrp_checkin:log', bed.Loc)
            ClearAround()
        end      
      end, function() -- Cancel
      end)
end






function Discharge()
    --TaskGoStraightToCoord(doctorPed, Config.DoctorPos, 30000, 1.2, 1.0, 1073741824, 0)
    --TaskGoStraightToCoord(doctorPed, Config.DoctorPos,  0.3,  -1,  0.0,  0.0)
    ClearAround()
end

function ClearAround()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    ClearPedSecondaryTask(ped)
    RequestAnimDict('switch@franklin@bed')
    while not HasAnimDictLoaded('switch@franklin@bed') do
        Wait(50)
    end
    SetEntityHeading(ped, GetEntityHeading(ped) + 90.0)
    TaskPlayAnim(ped, 'switch@franklin@bed', 'sleep_getup_rubeyes', -8.0, 8.0, 5000, 0, 0, 0, 0, 0)
    Wait(5000)
    FreezeEntityPosition(ped, false)
    isOnBed = false
    hasLeft = true
    currentBedCoords = nil
    markerCoords = nil
    shouldDrawMarker = false
end

function timeToDisp(time)
    local minutes = math.floor((time%3600/60))
    local seconds = math.floor((time%60))
    return string.format("%02dm %02ds",minutes,seconds)
end

function CreateDoctor()

    Wait(1000)

    RequestModel(`s_m_m_doctor_01`)
    while not HasModelLoaded(`s_m_m_doctor_01`) do
        Wait(10)
    end

    doctorPed = CreatePed(2, `s_m_m_doctor_01`, Config.DoctorPos, 156.0, false, true) -- I am not sure with the 20 as a param of pedType

    while not DoesEntityExist(doctorPed) do
        print('Waiting until the ped is created')
        Wait(10)
    end

    TaskGoStraightToCoord(doctorPed, vector3(315.53173828125,-581.87268066406,43.284164428711),  0.3,  -1,  0.0,  0.0)
    Wait(4000)
    ClearPedTasks(doctorPed)
    Wait(100)
    TaskGoStraightToCoord(doctorPed, GetEntityCoords(PlayerPedId()),  0.3,  -1,  0.0,  0.0)
    SetEntityMaxSpeed(doctorPed, 1.3)
    while (#(GetEntityCoords(doctorPed) - GetEntityCoords(PlayerPedId()))) > 1.5 do
        if isOnBed then
            Wait(500)
        else
            break
        end
        Wait(0)
    end

    ClearPedTasksImmediately(doctorPed)
    TaskLookAtEntity(doctorPed, PlayerPedId(), 10000, 2048, 3)

    if isOnBed then

        local clipModel = CreateObject(GetHashKey('p_amb_clipboard_01'), GetEntityCoords(doctorPed), true, true, true)
        local penModel = CreateObject(GetHashKey('prop_pencil_01'), GetEntityCoords(doctorPed), true, true, true)

        while not DoesEntityExist(clipModel) or not DoesEntityExist(penModel) do
            Wait(0)
        end

        AttachEntityToEntity(penModel, doctorPed,  GetPedBoneIndex(doctorPed, 58866), 0.12, 0.00, 0.001, -150.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
        AttachEntityToEntity(clipModel, doctorPed,  GetPedBoneIndex(doctorPed, 18905), 0.10, 0.02, 0.08, -68.0, 0.0, -40.0, 1, 1, 0, 1, 0, 1)
        TaskPlayAnim(doctorPed, 'missheistdockssetup1clipboard@base', 'base', 8.0, -8.0, 5000, 49, 0, false, false, false)

        Wait(5000)
        ClearPedTasks(doctorPed)
        DeleteObject(clipModel)
        DeleteObject(penModel)

    end

    --TaskGoStraightToCoord(doctorPed, Config.DoctorPos, 30000, 1.5, 1.0, 1073741824, 0) -- For me the bellow was better

    TaskGoStraightToCoord(doctorPed, vector3(315.53173828125,-581.87268066406,43.284164428711),  0.3,  -1,  0.0,  0.0)
    Wait(4000)
    ClearPedTasks(doctorPed)
    Wait(100)

    TaskGoStraightToCoord(doctorPed, Config.DoctorPos,  0.3,  -1,  0.0,  0.0)

    while (#(GetEntityCoords(doctorPed) - Config.DoctorPos)) > 1.5 do
        Wait(500)
    end

    DeleteEntity(doctorPed)

end

function StartClipBoardAnim(closestBed)
    local ped = PlayerPedId()

    RequestAnimDict('missheistdockssetup1clipboard@base')
    while not HasAnimDictLoaded('missheistdockssetup1clipboard@base') do
        Wait(10)
    end

    local clipModel = CreateObject(GetHashKey('p_amb_clipboard_01'), GetEntityCoords(ped), true, true, true)
    local penModel = CreateObject(GetHashKey('prop_pencil_01'), GetEntityCoords(ped), true, true, true)
    while not DoesEntityExist(clipModel) or not DoesEntityExist(penModel) do
        Wait(0)
    end

    AttachEntityToEntity(penModel, ped,  GetPedBoneIndex(PlayerPedId(), 58866), 0.12, 0.00, 0.001, -150.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
    AttachEntityToEntity(clipModel, ped,  GetPedBoneIndex(PlayerPedId(), 18905), 0.10, 0.02, 0.08, -68.0, 0.0, -40.0, 1, 1, 0, 1, 0, 1)
    TaskPlayAnim(ped, 'missheistdockssetup1clipboard@base', 'base', 8.0, -8.0, 5000, 49, 0, false, false, false)
    Wait(5000)

    DeleteEntity(clipModel)
    DeleteEntity(penModel)
    ClearPedTasks(ped)
    GetOnTheBed(closestBed)
    Wait(10)

    -- For now TaskGoToCoord does not work in the interiors, not sure why, I will be testing it in the future
    --[[for i=1, #Config.CheckPoints do
        print('Going for checkpoint: %s', i)
        TaskGoToCoordAnyMeans(PlayerPedId(), Config.CheckPoints[i], 1.0, 0, 0, 786603, 1.0)
        while (#(GetEntityCoords(PlayerPedId()) - Config.CheckPoints[i])) > 0.5 do
            print(#(GetEntityCoords(PlayerPedId()) - Config.CheckPoints[i]))
            Wait(500)
        end
    end--]]

    FreezeEntityPosition(PlayerPedId(), false)

    markerCoords = closestBed.Loc
    shouldDrawMarker = true
    local attempt = 0

    while (#(GetEntityCoords(PlayerPedId()) - closestBed.Loc)) > 1.5 and attempt < 61 do
        Wait(500)
        attempt = attempt + 1

    end
    shouldDrawMarker = false
    GetOnTheBed(closestBed)
    CreateDoctor()

end

--[[Citizen.CreateThread(function()
    AddTextEntry('reception', '~INPUT_PICKUP~ Check in')
    while true do
        Wait(0)
        local pedPos = GetEntityCoords(PlayerPedId())
        local dist = #(Config.ReceptionPos - pedPos)
        if dist > 10.0 then
            Wait(500)
        else
            if dist < 2.0 then
                BeginTextCommandDisplayHelp('reception')
                EndTextCommandDisplayHelp(1, 0, 0, 0)
                SetFloatingHelpTextWorldPosition(0, Config.ReceptionPos)
                SetFloatingHelpTextStyle()
                if IsControlPressed(0, 38) then

                    --SetEntityHealth(PlayerPedId(), 100) -- Remove after testing !!! Used only for testing

                    FreezeEntityPosition(PlayerPedId(), true)
                    local closestBed = GetFreeBed()

                    if closestBed then
                        StartClipBoardAnim(closestBed)
                    end
                end
            end
        end

    end

end)--]]


exports['qb-target']:AddBoxZone("recepceEMS", vector3(312.18, -593.43, 44.01), 1.5, 1.5, { -- The name has to be unique, the coords a vector3 as shown, the 1.5 is the length of the boxzone and the 1.6 is the width of the boxzone, the length and width have to be float values
  name = "checkin", -- This is the name of the zone recognized by PolyZone, this has to be unique so it doesn't mess up with other zones
  heading = -22.0, -- The heading of the boxzone, this has to be a float value
  debugPoly = false, -- This is for enabling/disabling the drawing of the box, it accepts only a boolean value (true or false), when true it will draw the polyzone in green
  minZ = 42.7, -- This is the bottom of the boxzone, this can be different from the Z value in the coords, this has to be a float value
  maxZ = 43.9, -- This is the top of the boxzone, this can be different from the Z value in the coords, this has to be a float value
}, {
  options = { -- This is your options table, in this table all the options will be specified for the target to accept
    { -- This is the first table with options, you can make as many options inside the options table as you want
      num = 1, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
      type = "client", -- This specifies the type of event the target has to trigger on click, this can be "client", "server", "command" or "qbcommand", this is OPTIONAL and will only work if the event is also specified
      event = "checkin:test", -- This is the event it will trigger on click, this can be a client event, server event, command or qbcore registered command, NOTICE: Normal command can't have arguments passed through, QBCore registered ones can have arguments passed through
      icon = 'fas fa-eye', -- This is the icon that will display next to this trigger option
      label = 'Ošetření 1000$', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
      targeticon = 'fas fa-eye', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
    }
},
  distance = 2.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
})



-- Used for animations testing
--[[RegisterCommand("r", function()
    
    RequestAnimDict('missfbi1')
    while not HasAnimDictLoaded('missfbi1') do
        Wait(50)
    end
    SetEntityHeading(PlayerPedId(), 350.0)
    FreezeEntityPosition(PlayerPedId(), true)
    TaskPlayAnim(PlayerPedId(), 'missfbi1', 'cpr_pumpchest_idle', -8.0, 8.0, -1, 0, 0, false, false, false)
    Wait(5000)
    FreezeEntityPosition(PlayerPedId(), false)
    
end)

RegisterCommand('rr', function()

    ClearPedTasksImmediately(PlayerPedId())
    
end, false)]]

RegisterNetEvent('checkin:test')
AddEventHandler('checkin:test' ,function()
    local closestBed = GetFreeBed()
    if closestBed then
        QBCore.Functions.TriggerCallback('nwrp_checkin:canpay', function(can)
            if can then
                FreezeEntityPosition(PlayerPedId(), true)
                StartClipBoardAnim(closestBed)
                QBCore.Functions.Notify('Ošetření bylo zaplaceno', 'success')
            else
                QBCore.Functions.Notify('Nemáš dostatek peněz', 'error')
            end
        end)
    else
        QBCore.Functions.Notify('Není volná žádná postel', 'error')
    end
end)