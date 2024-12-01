Status = 'hold'
name = 'System'
input = 'hold'
cooldownActive = false
cooldownTimer = 15 * 60 -- Default cooldown in seconds (15 minutes)
robberiesDisabled = true

RegisterServerEvent('priority:fetchPriority')
AddEventHandler('priority:fetchPriority', function()
    TriggerClientEvent('priority:updateNUI', source, Status, { status = Status, name = name, input = input })
end)

CreateThread(function()
    while true do
        if cooldownActive then
            if cooldownTimer > 0 then
                cooldownTimer = cooldownTimer - 1
            elseif cooldownTimer == 0 then
                Status = 'safe'
                name = 'POLICE'
                input = 'safe'
                cooldownActive = false
                cooldownTimer = 15 * 60
                robberiesDisabled = false
            end
            TriggerClientEvent('priority:updateNUI', -1, Status, { status = Status, name = name, input = input, cooldown = cooldownTimer })
        end
        Wait(1000)
    end
end)

local function getName(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        return xPlayer.getName()
    end
    return GetPlayerName(src)
end

local webhookUrl = "" -- webhook

function getCurrentTime()
    local time = os.date("!%Y-%m-%d %H:%M:%S")
    return time
end

function sendToDiscord(message, title)
    local currentTime = getCurrentTime()
    local embed = {
        {
            ["color"] = 3447003,
            ["title"] = "CAT DEV PRIO",
            ["description"] = message,
            ["fields"] = {
                {["name"] = "Time", ["value"] = currentTime, ["inline"] = true}
            },
            ["footer"] = {
                ["text"] = "CAT DEV TEAM"
            }
        }
    }
    PerformHttpRequest(webhookUrl, function(statusCode, response, headers)
    end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
end

RegisterServerEvent('priority:PriorityCD')
AddEventHandler('priority:PriorityCD', function(cooldownDuration)
    Status = 'cooldown'
    name = getName(source)
    input = 'cooldown'
    
    if cooldownDuration and type(cooldownDuration) == "number" then
        cooldownTimer = cooldownDuration * 60
    else
        cooldownTimer = 15 * 60
    end

    cooldownActive = true
    robberiesDisabled = true
    TriggerClientEvent('priority:updateNUI', -1, Status, {
        status = Status,
        name = name,
        input = input,
        cooldown = cooldownTimer
    })

    sendToDiscord(string.format("Priority Event: %s | Status: %s | Name: %s | Cooldown: %d seconds", 'PriorityCD', Status, name, cooldownTimer), "Priority Event: PriorityCD")
end)

RegisterServerEvent('priority:PriorityIP')
AddEventHandler('priority:PriorityIP', function(priorityName)
    local _source = source
    Status = 'inprogress'
    name = priorityName or 'Unknown'
    input = 'inprogress'
    cooldownActive = false
    cooldownTimer = 15 * 60
    robberiesDisabled = true
    
    TriggerClientEvent('priority:updateNUI', -1, Status, { status = Status, name = name, input = input })
        
    sendToDiscord(string.format("Priority Event: %s | Status: %s | Name: %s", 'PriorityIP', Status, name), "Priority Event: PriorityIP")
end)

RegisterServerEvent('priority:PriorityHOLD')
AddEventHandler('priority:PriorityHOLD', function()
    Status = 'hold'
    name = getName(source)
    input = 'hold'
    cooldownActive = false
    cooldownTimer = 15 * 60
    robberiesDisabled = true
    TriggerClientEvent('priority:updateNUI', -1, Status, { status = Status, name = name, input = input })

    sendToDiscord(string.format("Priority Event: %s | Status: %s | Name: %s", 'PriorityHOLD', Status, name), "Priority Event: PriorityHOLD")
end)

RegisterServerEvent('priority:PrioritySAFE')
AddEventHandler('priority:PrioritySAFE', function()
    Status = 'safe'
    name = getName(source)
    input = 'safe'
    cooldownActive = false
    cooldownTimer = 15 * 60
    robberiesDisabled = false
    TriggerClientEvent('priority:updateNUI', -1, Status, { status = Status, name = name, input = input })

    sendToDiscord(string.format("Priority Event: %s | Status: %s | Name: %s", 'PrioritySAFE', Status, name), "Priority Event: PrioritySAFE")
end)


RegisterNetEvent('priority:updateNUI')
AddEventHandler('priority:updateNUI', function(prioType, prioData)
    if prioType == 'safe' or prioType == 'hold' then
        SendNUIMessage({ type = prioData.status, display = prioData.input, name = prioData.name })
    elseif prioType == 'inprogress' then
        SendNUIMessage({ type = prioData.status, display = prioData.input, name = prioData.name, location = prioData.location })
    elseif prioType == 'cooldown' then
        SendNUIMessage({ type = prioData.status, display = prioData.input, cooldown = prioData.cooldown, name = prioData.name })
    end

    ESX.PlayerData.robberiesDisabled = prioType == 'hold' or prioType == 'inprogress'
end)
