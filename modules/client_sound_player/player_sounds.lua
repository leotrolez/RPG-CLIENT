local CODE = 122

local soundChannels = {}
local maxChannels = 70 
local channelTimers = {}


for i = 1, maxChannels do
    local channel = g_sounds.getChannel(SoundChannels["Spells" .. i])
    if channel then
        soundChannels[i] = channel
    else
        print("Failed to initialize sound channel " .. i)
    end
end

function onExtendedOpcode(protocol, code, buffer)

    local json_status, json_data = pcall(function()
        return json.decode(buffer)
    end)

    if not json_status then
        print("Error decoding JSON: " .. json_data)
        return false
    end

    local action = json_data.action
    local soundFile = json_data.data

    local soundFilePath = "sounds/" .. soundFile

    if g_resources.fileExists(soundFilePath) then
        playSound(soundFilePath)
    else
        print("Sound file does not exist: " .. soundFilePath)
    end
end

function playSound(sound)
    local channel = findAvailableChannel()
    if not channel then
        print("No available sound channels.")
        return
    end

    channel:play(sound, 0, 1.0)
    channel:setGain(1.0)

    local duration = getSoundDuration(sound) or 3000
    channelTimers[channel] = scheduleEvent(function()
        channelTimers[channel] = nil
    end, duration)
end

function findAvailableChannel()
    for _, channel in ipairs(soundChannels) do
        if not channelTimers[channel] then
            return channel
        end
    end
    return nil
end

function getSoundDuration(sound)
    return 3000
end

function init()
    ProtocolGame.registerExtendedOpcode(CODE, onExtendedOpcode)
end

function terminate()
    ProtocolGame.unregisterExtendedOpcode(CODE)
end
