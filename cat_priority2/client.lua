local nuiReady = false

RegisterNUICallback('nuiReady', function(data, cb)
    print('[^4Priority^0] NUI Ready')
    nuiReady = true
    cb(true)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true

    while not ESX.PlayerData.ped do Wait(20) end

    TriggerServerEvent('priority:fetchPriority')
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('priority:updateNUI')
AddEventHandler('priority:updateNUI', function(prioType, prioData)
    local displayMessage = prioData.name  -- Default display message

    -- Include location in the display message if it's an inprogress robbery
    if prioType == 'inprogress' and prioData.location then
        displayMessage = "-" .. prioData.location
    end

    -- Display different status types with NUI
    if prioType == 'safe' or prioType == 'hold' then
        SendNUIMessage({ type = prioData.status, display = prioData.input, name = displayMessage })
    elseif prioType == 'inprogress' then
        SendNUIMessage({ type = prioData.status, display = prioData.input, name = displayMessage })
    elseif prioType == 'cooldown' then
        SendNUIMessage({ type = prioData.status, display = prioData.input, cooldown = prioData.cooldown, name = displayMessage })
    end

    -- Disable robberies if in "hold" or "inprogress"
    ESX.PlayerData.robberiesDisabled = prioType == 'hold' or prioType == 'inprogress' or prioType == 'cooldown'
end)

RegisterCommand('pdcooldown', function(source, args)
    local cooldownDuration = tonumber(args[1]) -- Get the cooldown duration from the first argument
    if not cooldownDuration then
        TriggerServerEvent('priority:PriorityCD', 15)
        return
    end
    
    if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'admin' then
        TriggerServerEvent('priority:PriorityCD', cooldownDuration) -- Pass the duration to the server event
    else
        print('bawal ka!')
    end
end)

RegisterCommand('pdinprogress', function()
    if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'admin' then
        -- Use the lib.inputDialog to prompt for the priority name
        local input = lib.inputDialog('Manual In-progress', {'What is Your Latest 10-90? Car Chase / Traphouse / Kidnap / Turfwar?'})

        -- Check if the player entered something
        if not input then return end
        local priorityName = input[1]  -- Get the entered name

        if priorityName and priorityName ~= "" then
            -- Trigger the server event with the entered name
            TriggerServerEvent('priority:PriorityIP', priorityName)
        else
            -- Notify the player that they need to enter a valid name
            TriggerEvent('ox_lib:notify', {
                id = 'error',
                title = 'Error',
                description = 'You must enter a name for the priority!',
                position = 'bottom',
                type = 'error',
                duration = 5000
            })
        end
    else
        print('bawal ka!')  -- This is an error message for players who are not in police or ambulance job
    end
end)



RegisterCommand('pdsafe', function()
    if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'admin' then
        TriggerServerEvent('priority:PrioritySAFE')
    else
        print('bawal ka!')
    end
end)

RegisterCommand('pdhold', function()
    if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'admin' then
        TriggerServerEvent('priority:PriorityHOLD')
    else
        print('bawal ka!')
    end
end)

local isPrioVisible = false  -- Variable to keep track of the UI visibility

RegisterCommand("pdprio", function()
    -- Toggle the visibility of the priority UI
    if isPrioVisible then
        SendNUIMessage({
            type = "display",
            display = true  -- Send message to hide the UI
        })
    else
        SendNUIMessage({
            type = "display",
            display = false  -- Send message to display the UI
        })
    end

    -- Toggle the visibility flag
    isPrioVisible = not isPrioVisible
end, false)

