Status = 'hold'
name = 'System'
input = 'hold'
cooldownActive = false
cooldownTimer = 15 * 60 -- Default cooldown in seconds (15 minutes)
robberiesDisabled = true

RegisterServerEvent('priority2:fetchPriority')
AddEventHandler('priority2:fetchPriority', function()
    TriggerClientEvent('priority2:updateNUI', source, Status, { status = Status, name = name, input = input })
end)

CreateThread(function()
    while true do
        if cooldownActive then
            if cooldownTimer > 0 then
                cooldownTimer = cooldownTimer - 1
            elseif cooldownTimer == 0 then
                Status = 'safe'
                name = 'SHERIFF'
                input = 'safe'
                cooldownActive = false
                cooldownTimer = 15 * 60 -- Reset default cooldown to 15 minutes in seconds
                robberiesDisabled = false
            end
            TriggerClientEvent('priority2:updateNUI', -1, Status, { status = Status, name = name, input = input, cooldown = cooldownTimer })
        end
        Wait(1000) -- every second
    end
end)

local function getName(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        return xPlayer.getName()
    end
    return GetPlayerName(src)
end

local webhookUrl = "https://discord.com/api/webhooks/1312085557685391410/xuZfMq3xP3cF7PLK3ildxohNK-cPOBmGUOEWbei5NYQeqaY8x03qVQ8VDhzCD6KSSDzX"

-- Function to get the current time and date in a readable format
function getCurrentTime()
    local time = os.date("!%Y-%m-%d %H:%M:%S")  -- Format: YYYY-MM-DD HH:MM:SS (UTC)
    return time
end

-- Function to send log messages to Discord with embed
function sendToDiscord(message, title)
    local currentTime = getCurrentTime()
    local embed = {
        {
            ["color"] = 3447003,  -- Blue color for the embed
            ["title"] = "CD_PRIORITY",
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
        -- You can add more logging here if needed
    end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
end

RegisterServerEvent('priority2:PriorityCD')
AddEventHandler('priority2:PriorityCD', function(cooldownDuration)
    Status = 'cooldown'
    name = getName(source)
    input = 'cooldown'
    
    -- Set the cooldown duration in seconds, defaulting to 15 minutes if no valid duration is provided
    if cooldownDuration and type(cooldownDuration) == "number" then
        cooldownTimer = cooldownDuration * 60 -- Convert minutes to seconds
    else
        cooldownTimer = 15 * 60 -- Default cooldown duration (15 minutes in seconds)
    end

    cooldownActive = true
    robberiesDisabled = true
    TriggerClientEvent('priority2:updateNUI', -1, Status, {
        status = Status,
        name = name,
        input = input,
        cooldown = cooldownTimer
    })

    -- Send log to Discord with embed
    sendToDiscord(string.format("Priority Event: %s | Status: %s | Name: %s | Cooldown: %d seconds", 'PriorityCD', Status, name, cooldownTimer), "Priority Event: PriorityCD")
end)

RegisterServerEvent('priority2:PriorityIP')
AddEventHandler('priority2:PriorityIP', function(priorityName)
    local _source = source
    Status = 'inprogress'
    name = priorityName or 'Unknown'
    input = 'inprogress'
    cooldownActive = false
    cooldownTimer = 15 * 60
    robberiesDisabled = true
    
    TriggerClientEvent('priority2:updateNUI', -1, Status, { status = Status, name = name, input = input })

    -- Send log to Discord with embed
    sendToDiscord(string.format("Priority Event: %s | Status: %s | Name: %s", 'PriorityIP', Status, name), "Priority Event: PriorityIP")
end)

RegisterServerEvent('priority2:PriorityHOLD')
AddEventHandler('priority2:PriorityHOLD', function()
    Status = 'hold'
    name = getName(source)
    input = 'hold'
    cooldownActive = false
    cooldownTimer = 15 * 60
    robberiesDisabled = true
    TriggerClientEvent('priority2:updateNUI', -1, Status, { status = Status, name = name, input = input })

    -- Send log to Discord with embed
    sendToDiscord(string.format("Priority Event: %s | Status: %s | Name: %s", 'PriorityHOLD', Status, name), "Priority Event: PriorityHOLD")
end)

RegisterServerEvent('priority2:PrioritySAFE')
AddEventHandler('priority2:PrioritySAFE', function()
    Status = 'safe'
    name = getName(source)
    input = 'safe'
    cooldownActive = false
    cooldownTimer = 15 * 60
    robberiesDisabled = false
    TriggerClientEvent('priority2:updateNUI', -1, Status, { status = Status, name = name, input = input })

    -- Send log to Discord with embed
    sendToDiscord(string.format("Priority Event: %s | Status: %s | Name: %s", 'PrioritySAFE', Status, name), "Priority Event: PrioritySAFE")
end)


RegisterNetEvent('priority2:updateNUI')
AddEventHandler('priority2:updateNUI', function(prioType, prioData)
    if prioType == 'safe' or prioType == 'hold' then
        SendNUIMessage({ type = prioData.status, display = prioData.input, name = prioData.name })
    elseif prioType == 'inprogress' then
        SendNUIMessage({ type = prioData.status, display = prioData.input, name = prioData.name, location = prioData.location })
    elseif prioType == 'cooldown' then
        SendNUIMessage({ type = prioData.status, display = prioData.input, cooldown = prioData.cooldown, name = prioData.name })
    end

    ESX.PlayerData.robberiesDisabled = prioType == 'hold' or prioType == 'inprogress'
end)
