local REPUTATION_OPCODE = 99
local reputationWindow = nil
local reputationButton = nil
local reputationData = {}

reputationTooltip = 'Your Reputation of %s is %d of %d. Your Rank: %s'

function init()
    connect(g_game, { onGameStart = updateReputationWindow })

    if g_game.isOnline() then
        updateReputationWindow()
    end
    ProtocolGame.registerExtendedOpcode(REPUTATION_OPCODE, onExtendedOpcode)

    reputationButton = modules.client_topmenu.addRightGameToggleButton("reputationButton", tr("Reputation"), "/images/topbuttons/reputation", toggleReputationWindow)
    reputationButton:setOn(true)
    
    reputationWindow = g_ui.loadUI("reputation", modules.game_interface.getRightPanel())
    reputationWindow:setup()
end

function terminate()
    disconnect(g_game, { onGameStart = updateReputationWindow })
    ProtocolGame.unregisterExtendedOpcode(REPUTATION_OPCODE)

    if reputationButton then
        reputationButton:destroy()
        reputationButton = nil
    end

    if reputationWindow then
        reputationWindow:destroy()
        reputationWindow = nil
    end
end

function onExtendedOpcode(protocol, code, buffer)
    local json_status, json_data = pcall(function() return json.decode(buffer) end)

    if not json_status then
        g_logger.error("[Reputation] JSON error: " .. json_data)
        return false
    end

    reputationData = json_data
    updateReputationWindow()
end
  
function updateReputationWindow()
    local content = reputationWindow:getChildById("contentsPanel")

    content:destroyChildren()

    for _, reputationEntry in ipairs(reputationData) do
        local reputationWidget = content:getChildById(reputationEntry.storage)
        
        if not reputationWidget then
            reputationWidget = g_ui.createWidget("ReputationPanel", content)
            reputationWidget:setId(reputationEntry.storage)
        end

        local current = tonumber(reputationEntry.current) or 0
        local max = tonumber(reputationEntry.max) or 1


        local nameLabel = reputationWidget:getChildById("name")
        local rankLabel = reputationWidget:getChildById("rank")
        local progressBar = reputationWidget:getChildById("reputationBar")

        if nameLabel then
            nameLabel:setText(reputationEntry.name)
            nameLabel:setColor("white")

            local factionImage = reputationWidget:getChildById("factionImage")
                if factionImage then
                if reputationEntry.name == "Vardenfell" then
                    factionImage:setImageSource("/images/game/reputation/vardenfell_reputation")
                elseif reputationEntry.name == "Dorn" then
                    factionImage:setImageSource("/images/game/reputation/dorn_reputation")
                elseif reputationEntry.name == "Frosthold" then
                    factionImage:setImageSource("/images/game/reputation/frosthold_reputation")
                elseif reputationEntry.name == "Hallowfall" then
                    factionImage:setImageSource("/images/game/reputation/hallowfall_reputation")
                elseif reputationEntry.name == "Vyrsk" then
                    factionImage:setImageSource("/images/game/reputation/vyrsk_reputation")
                else
                    factionImage:setImageSource("/images/game/reputation/vardenfell_reputation")
                end
            end
        else
            print("Error: Name label not found in widget")
        end


        local percentage = (current / max) * 100
        percentage = math.max(0, math.min(100, percentage))


        if progressBar then
            progressBar:setValue(current, 0, max)
        else
            print("Error: ProgressBar not found in widget")
        end

        local progressColor
        if percentage > 75 then
            progressColor = "#00BC00FF"
        elseif percentage > 50 then
            progressColor = "#50A150FF"
        elseif percentage > 25 then
            progressColor = "#A1A100FF"
        elseif percentage > 10 then
            progressColor = "#BF0A0AFF"
        else
            progressColor = "#FF0000FF"
        end

        if rankLabel then
            local rank = reputationEntry.rank
        
            if rank == "Unfriendly" then
                rankLabel:setText(rank)
                rankLabel:setColor("#b84848") -- Red-ish for Unfriendly
            elseif rank == "Neutral" then
                rankLabel:setText(rank)
                rankLabel:setColor("#e6805e") -- Orange for Neutral
            elseif rank == "Friendly" then
                rankLabel:setText(rank)
                rankLabel:setColor("#e6b05e") -- Yellow for Friendly
            elseif rank == "Honored" then
                rankLabel:setText(rank)
                rankLabel:setColor("#e6df5e") -- Light Yellow for Honored
            elseif rank == "Revered" then
                rankLabel:setText(rank)
                rankLabel:setColor("#c2e65e") -- Light Green for Revered
            elseif rank == "Exalted" then
                rankLabel:setText(rank)
                rankLabel:setColor("#5ee660") -- Green for Exalted
            elseif rank == "Majestic" then
                rankLabel:setText(rank)
                rankLabel:setColor("#5ee6cb") -- Blue-ish for Majestic
            else
                print("Error: Unknown rank: " .. tostring(rank))
            end
        else
            print("Error: Rank label not found in widget")
        end
        

        if progressBar then
            progressBar:setBackgroundColor(progressColor)
            progressBar:setText(comma_value(current) .. ' / ' .. comma_value(max))
            progressBar:setTooltip(tr(reputationTooltip, reputationEntry.name, current, max, reputationEntry.rank))
        end
        local coinLabel = reputationWidget:getChildById("coinLabel")
        local coinImage = reputationWidget:getChildById("coinImage")

        if not coinLabel then
            coinLabel = g_ui.createWidget("Label", reputationWidget)
            coinLabel:setId("coinLabel")
            coinLabel:setColor("#ff7700")
        end

        if not coinImage then
            coinImage = g_ui.createWidget("Image", reputationWidget)
            coinImage:setId("coinImage")
        end

        if coinLabel then
            coinLabel:setText(reputationEntry.coin .. ": " .. reputationEntry.coinValue)
            coinLabel:setMarginLeft(40)
        if reputationEntry.coin == "Vardenfell Coins" then
            coinImage:setImageSource("/images/game/reputation/coins")
        elseif reputationEntry.coin == "Dorn Coins" then
            coinImage:setImageSource("/images/game/reputation/coins")
        elseif reputationEntry.coin == "Frosthold Coins" then
            coinImage:setImageSource("/images/game/reputation/coins")
        elseif reputationEntry.coin == "Hallowfall Coins" then
            coinImage:setImageSource("/images/game/reputation/coins")
        elseif reputationEntry.coin == "Vyrsk Coins" then
            coinImage:setImageSource("/images/game/reputation/coins")
        else
            coinImage:setImageSource("/images/game/reputation/coins")
        end
    end
    end
end

function toggleReputationWindow()
    if reputationWindow:isVisible() then
        reputationWindow:close()
        reputationButton:setOn(false)
    else
        reputationWindow:open()
        reputationButton:setOn(true)
    end
end
