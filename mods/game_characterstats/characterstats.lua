local CODE = 106

local statsWindow = nil
local statsButton = nil

local remainingPoints = 0

function init()
  connect(
    g_game,
    {
      onGameStart = refresh
    }
  )

  ProtocolGame.registerExtendedOpcode(CODE, onExtendedOpcode)

  statsButton = modules.client_topmenu.addRightGameToggleButton("statsButton", tr("Character Stats"), "/images/topbuttons/character_stats", toggle, false, 1)
  statsButton:setOn(true)
  statsWindow = g_ui.loadUI("characterstats", modules.game_interface.getRightPanel())

  statsWindow:setContentMaximumHeight(290)

  statsWindow:setup()

  local content = statsWindow:getChildById("contentsPanel")
  local stats = {"strength", "intelligence", "dexterity", "vitality", "spirit"}
  for i = 1, #stats do
    local statWidget = content:getChildById(stats[i])
    statWidget:getChildById("plusButton").onClick = addStat
    statWidget:getChildById("minusButton").onClick = removeStat
  end
end

function terminate()
  disconnect(
    g_game,
    {
      onGameStart = refresh
    }
  )

  ProtocolGame.unregisterExtendedOpcode(CODE, onExtendedOpcode)

  if statsButton then
    statsButton:destroy()
    statsButton = nil
  end

  if statsWindow then
    statsWindow:destroy()
    statsWindow = nil
  end
end

function onExtendedOpcode(protocol, code, buffer)
  local json_status, json_data =
    pcall(
    function()
      return json.decode(buffer)
    end
  )

  if not json_status then
    g_logger.error("[Character Stats] JSON error: " .. data)
    return false
  end

  local action = json_data.action
  local data = json_data.data

  if action == "update" then
    update(data)
  end
end

function addStat(widget)
  if remainingPoints <= 0 then
    return
  end
  local parent = widget:getParent()
  local statId = parent:getId()
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(CODE, json.encode({action = "add", data = statId}))
  end
end

function removeStat(widget)
  local parent = widget:getParent()
  local statId = parent:getId()
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(CODE, json.encode({action = "remove", data = statId}))
  end
end

function resetStats()
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(CODE, json.encode({action = "reset"}))
  end
end

function update(data)
  local content = statsWindow:getChildById("contentsPanel")

  content:recursiveGetChildById("remainingPoints"):setText("Points: " .. data.points)
  remainingPoints = data.points

  for key, stat in pairs(data.stats) do
    local statWidget = content:getChildById(key)
    statWidget:getChildById("points"):setText(stat.points)
    statWidget:getChildById("value"):setText("+" .. stat.value .. "%")
  end
end

function toggle()
  if statsButton:isOn() then
    statsWindow:close()
    statsButton:setOn(false)
  else
    statsWindow:open()
    statsButton:setOn(true)
  end
end

function onMiniWindowClose()
  statsButton:setOn(false)
end

function hide()
  statsWindow:hide()
end

function show()
  statsWindow:show()
end
