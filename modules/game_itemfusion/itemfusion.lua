local itemFusionWindow, confirmFusionWindow = nil
local CODE = 67
local fusionButton = nil

function init()
  fusionButton = modules.client_topmenu.addRightGameToggleButton('fusionButton', tr('Fusion'), '/images/topbuttons/fusion', toggle, false, 8)
  ProtocolGame.registerExtendedOpcode(CODE, onExtendedOpcode)

  itemFusionWindow = g_ui.displayUI("itemfusion")
  if not itemFusionWindow then
    return
  end

  itemFusionWindow.onDestroy = function()
    terminate()
  end

  connect(g_game, { onGameEnd = close })
  itemFusionWindow:hide()

  local item1 = itemFusionWindow:recursiveGetChildById("item1")
  local item2 = itemFusionWindow:recursiveGetChildById("item2")
  local item3 = itemFusionWindow:recursiveGetChildById("item3")
  if item1 then item1.onDrop = onDrop end
  if item2 then item2.onDrop = onDrop end
  if item3 then item3.onDrop = onDrop end
  return 
end

function toggle()
  if itemFusionWindow:isVisible() then
    close()
  else
    show()
  end
end

function terminate()
  pcall(function()
    ProtocolGame.unregisterExtendedOpcode(CODE)
  end)
  if itemFusionWindow then
    itemFusionWindow:destroy()
    itemFusionWindow = nil
  end
  if confirmFusionWindow then
    confirmFusionWindow:destroy()
    confirmFusionWindow = nil
  end
  if fusionButton then
    fusionButton:destroy()
    fusionButton = nil
  end
  disconnect(g_game, { onGameEnd = close })
end

function show()
  clearItems()
  itemFusionWindow:show()
  return 
end

function close()
  clearItems()
  itemFusionWindow:hide()
  return 
end

function getItems()
  local items = {}
  local item1 = itemFusionWindow:recursiveGetChildById("item1")
  local item2 = itemFusionWindow:recursiveGetChildById("item2")
  local item3 = itemFusionWindow:recursiveGetChildById("item3")
  
  if item1 then
    local it = item1:getItem()
    if it then
      items[#items + 1] = {
        index = it:getId(),
        itemPosition = it:getPosition(),
        clientId = it:getId(),
        serverId = it:getServerId(),
        stackPos = it:getStackPos()
      }
    end
  end
  if item2 then
    local it = item2:getItem()
    if it then
      items[#items + 1] = {
        index = it:getId(),
        itemPosition = it:getPosition(),
        clientId = it:getId(),
        serverId = it:getServerId(),
        stackPos = it:getStackPos()
      }
    end
  end
  if item3 then
    local it = item3:getItem()
    if it then
      items[#items + 1] = {
        index = it:getId(),
        itemPosition = it:getPosition(),
        clientId = it:getId(),
        serverId = it:getServerId(),
        stackPos = it:getStackPos()
      }
    end
  end
  return items
end

function clearItems()
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame.sendExtendedOpcode(protocolGame, CODE, json.encode({
      action = "clear_items",
      items = getItems()
    }))
  end

  local item1 = itemFusionWindow:recursiveGetChildById("item1")
  local item2 = itemFusionWindow:recursiveGetChildById("item2")
  local item3 = itemFusionWindow:recursiveGetChildById("item3")

  if item1 then
    item1:setItem()
    item1:setTooltip()
  end
  if item2 then
    item2:setItem()
    item2:setTooltip()
  end
  if item3 then
    item3:setItem()
    item3:setTooltip()
  end

  local resultItem = itemFusionWindow:recursiveGetChildById("resultItem")
    if resultItem then
        resultItem:setItem()
        resultItem:setTooltip()
    end
  return 
end

function onDrop(widget, droppedWidget)
  if not droppedWidget or type(droppedWidget.getItem) ~= "function" then
    return false
  end
    
  local item = droppedWidget:getItem()
    if not item then
      return false
    end

  local clientId = item:getId()
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame.sendExtendedOpcode(protocolGame, CODE, json.encode({
      action = "added_item",
      widgetId = widget:getId(),
      item = {
        index = clientId,
        itemPosition = item:getPosition(),
        clientId = clientId,
        serverId = 0,
        stackPos = item:getStackPos()
      },
      items = getItems()
    }))
    widget:setItem(item)
  else
    displayErrorBox(tr("Error"), tr("This item cannot be fused."))
  end
  return true
end

local rewardMapping = {
    ----- Item Fusions ------
    [29619] = { client = 26963, name = "Upgrade Rune v1" },
    [29620] = { client = 26964, name = "Upgrade Rune v2" },
    [29621] = { client = 26965, name = "Upgrade Rune v3" },
    [29622] = { client = 26966, name = "Upgrade Rune v4" },
    ----- Normal Fusions ------
    [26967] = { client = 29623, name = "Upgrade and Rarity Remover" },
  }

function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= CODE then
    return 
  end

  local data = json.decode(buffer)
  if type(data) ~= "table" then
    return 
  end

  if data.action == "show" then
    show()
  elseif data.action == "invalid_item" then
    local widget = itemFusionWindow[data.widgetId]
    if widget then
      widget:setItem()
      widget:setTooltip()
    end
    if data.message and data.message ~= "" then
      displayErrorBox(tr("Error"), tr(data.message))
    end
  elseif data.action == "update_tooltip" then
    local widget = itemFusionWindow[data.widgetId]
    if widget then
      widget:setTooltip(data.tooltip)
    end
  elseif data.action == "fused_success" then
    local mappingEntry = rewardMapping[data.outputId]
    local rewardClientId = mappingEntry and mappingEntry.client or data.outputId
    local rewardName = mappingEntry and mappingEntry.name or ""
    local resultItem = itemFusionWindow:recursiveGetChildById("resultItem")
    if resultItem then
        resultItem:setItemId(rewardClientId)
        resultItem:setTooltip(rewardName)
    else
    end
    displayErrorBox(tr("Success"), tr("Sucess! You obtained: " .. rewardName .. " by fusioning your items!"))
  end
  return
end

function acceptBox(title, message, onOk, onCancel)
  local box = g_ui.displayUI("acceptbox")
  if box then
    local titleWidget = box:getChildById("title")
    if titleWidget then
      titleWidget:setText(title)
    end
    local msgLabel = box:getChildById("message")
    if msgLabel then
      msgLabel:setText(message)
    end
    local yesButton = box:getChildById("yesButton")
    if yesButton then
      yesButton.onClick = function()
        if onOk then onOk() end
        box:destroy()
      end
    end
    local noButton = box:getChildById("noButton")
    if noButton then
      noButton.onClick = function()
        if onCancel then onCancel() end
        box:destroy()
      end
    end
    box:addAnchor(AnchorHorizontalCenter, 'parent', AnchorHorizontalCenter)
    box:addAnchor(AnchorVerticalCenter, 'parent', AnchorVerticalCenter)
  end
  return box
end

function fuseItems()
  local item1 = itemFusionWindow:recursiveGetChildById("item1"):getItem()
  local item2 = itemFusionWindow:recursiveGetChildById("item2"):getItem()
  local item3 = itemFusionWindow:recursiveGetChildById("item3"):getItem()

  if not item1 or not item2 or not item3 then
    displayErrorBox(tr("Error"), tr("You need 3 identical items to be fused."))
    return 
  end

  if confirmFusionWindow then
    confirmFusionWindow:destroy()
  end

  confirmFusionWindow = acceptBox(tr("Item Fusion"),
    "Are you sure you want to fuse these items?\n This action is irreversible.",
    function()
      confirmFusionWindow = nil
      local protocolGame = g_game.getProtocolGame()
      if protocolGame then
        protocolGame.sendExtendedOpcode(protocolGame, CODE, json.encode({
          action = "fuse",
          items = getItems()
        }))
      end
      clearItems()
    end,
    function()
      confirmFusionWindow = nil
    end
  )
end

return {
  init = init,
  terminate = terminate,
  fuseItems = fuseItems,
  clearItems = clearItems,
  toggle = toggle,
  onDrop = onDrop,
  getItems = getItems
}
