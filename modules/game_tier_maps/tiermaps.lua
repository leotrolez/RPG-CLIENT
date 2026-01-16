local teleportWindow
local OPCODE = 202
local choiceWindow
local teleportButton

local function onDrop(widget, dragged)
  if not dragged or type(dragged.getItem) ~= "function" then return false end
  local item = dragged:getItem()
  if not item then return false end
  widget:setItem(item)
  return true
end

local function clearSlot()
  local slot = teleportWindow:getChildById("slot")
  slot:setItem()
  teleportWindow:hide()
end

local function requestWrap()
  g_game.getProtocolGame():sendExtendedOpcode(OPCODE, json.encode({
    action   = "wrap"
  }))
end

local function requestTeleport()
  local slot = teleportWindow:getChildById("slot")
  local item = slot:getItem()
  if not item then return end

  g_game.getProtocolGame():sendExtendedOpcode(OPCODE, json.encode({
    action   = "teleport",
    clientId = item:getId()
  }))
end

local function requestChoice()
  g_game.getProtocolGame():sendExtendedOpcode(OPCODE, json.encode({
    action = "choice"
  }))
end

function hideChoiceWindow()
  if choiceWindow and choiceWindow:isVisible() then
    choiceWindow:hide()
  end
end


local function showChoiceWindow(choices)
  if not choiceWindow then
    choiceWindow = g_ui.displayUI("padChoice")
    choiceWindow.onDestroy = function() choiceWindow = nil end
  else
    choiceWindow:raise()
  end

  local btnDefault = choiceWindow:getChildById("btnDefault")
  local btnStone  = choiceWindow:getChildById("btnStone")
  local btnGold   = choiceWindow:getChildById("btnGold")
  local btnBlood   = choiceWindow:getChildById("btnBlood")
  local btnPoisonous = choiceWindow:getChildById("btnPoisonous")
  local btnMaze = choiceWindow:getChildById("btnMaze")
  local btnRoyal = choiceWindow:getChildById("btnRoyal")
  local btnDemonic = choiceWindow:getChildById("btnDemonic")
  local btnPalace = choiceWindow:getChildById("btnPalace")
  local btnLion = choiceWindow:getChildById("btnLion")
  local btnUnderwater = choiceWindow:getChildById("btnUnderwater")
  local btnDivine = choiceWindow:getChildById("btnDivine")
  local btnInferno  = choiceWindow:getChildById("btnInferno")
  local btnJade = choiceWindow:getChildById("btnJade")

  btnDefault:disable()
  btnStone:disable()
  btnGold:disable()
  btnBlood:disable()
  btnPoisonous:disable()
  btnMaze:disable()
  btnRoyal:disable()
  btnDemonic:disable()
  btnPalace:disable()
  btnLion:disable()
  btnUnderwater:disable()
  btnDivine:disable()
  btnInferno:disable()
  btnJade:disable()

  for _, choice in ipairs(choices) do
    if choice.id == 0 then
      btnDefault:enable()
    elseif choice.id == 1 then
      btnStone:enable()
    elseif choice.id == 2 then
      btnGold:enable()
    elseif choice.id == 3 then
      btnBlood:enable()
    elseif choice.id == 4 then
      btnPoisonous:enable()
    elseif choice.id == 5 then
      btnMaze:enable()
    elseif choice.id == 6 then
      btnRoyal:enable()
    elseif choice.id == 7 then
      btnDemonic:enable()
    elseif choice.id == 8 then
      btnPalace:enable()
    elseif choice.id == 9 then
      btnLion:enable()
    elseif choice.id == 10 then
      btnUnderwater:enable()
    elseif choice.id == 11 then
      btnDivine:enable()
    elseif choice.id == 12 then
      btnInferno:enable()
    elseif choice.id == 13 then
      btnJade:enable()
    end
  end

  choiceWindow:show()
  choiceWindow:raise()
end

function onOptionClicked(choiceId)
  -- choiceId: 0,1, or 2
  g_game.getProtocolGame():sendExtendedOpcode(OPCODE, json.encode({
    action   = "choice_apply",
    choiceId = choiceId
  }))
  hideChoiceWindow()
end

local function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= OPCODE then return end
  local msg = json.decode(buffer)
  if msg.action == "show" then
  teleportWindow:show()
   return
  end
  if msg.action == "teleport_done" then
    teleportWindow:hide()
    clearSlot()
  elseif msg.action == "teleport_error" then
    displayErrorBox(tr("Error"), tr(msg.text or "Teleport failed."))
  elseif msg.action == "wrap_done" then
    teleportWindow:hide()
    clearSlot()
  elseif msg.action == "wrap_error" then
    displayErrorBox(tr("Error"), tr(msg.text or "Wrap failed."))
  elseif msg.action == "choice_show" then
    -- msg.choices might be e.g. { {id=0,text="Default"}, {id=1,text="Square"} }
    showChoiceWindow(msg.choices)
    return

  --------------------------------------------------------------------------------
  -- ★ NEW: server accepted our choiceApply → simply close the panel
  --------------------------------------------------------------------------------
  elseif msg.action == "choice_done" then
    hideChoiceWindow()
    return

  --------------------------------------------------------------------------------
  -- ★ NEW: server rejected our choiceApply (e.g. we tried to pick a pad we
  --   do not actually own) → show an error box
  --------------------------------------------------------------------------------
  elseif msg.action == "choice_error" then
    displayErrorBox(tr("Error"), tr(msg.text or "Invalid choice."))
    return
  end
end

local function showWindow()
  clearSlot()
  teleportWindow:show()
end

local function hideWindow()
  clearSlot()
  teleportWindow:hide()
end

local function toggleWindow()
  if teleportWindow:isVisible() then hideWindow() else showWindow() end
end

local helpWindow

local function showHelp()
  if not helpWindow then
    helpWindow = g_ui.displayUI("teleportHelp")
    helpWindow.onDestroy = function() helpWindow = nil end
  else
    helpWindow:raise()
  end
end

function closeHelpWindow()
  if helpWindow then
    helpWindow:hide()
    helpWindow = nil
  end
end

function init()
  ProtocolGame.registerExtendedOpcode(OPCODE, onExtendedOpcode)
  teleportWindow = g_ui.displayUI("tiermaps")
  if teleportWindow then
    teleportWindow:getChildById("btnHelp").onClick = showHelp
    teleportWindow:getChildById("btnChoice").onClick = requestChoice
    teleportWindow.onDestroy = terminate
    teleportWindow:hide()
    teleportWindow:getChildById("slot").onDrop   = onDrop
    teleportWindow:getChildById("btnTeleport").onClick = requestTeleport
    teleportWindow:getChildById("btnDecline").onClick  = clearSlot
    teleportWindow:getChildById("btnWrap").onClick = requestWrap
  end
  connect(g_game, { onGameEnd = hideWindow })
end

function terminate()
  ProtocolGame.unregisterExtendedOpcode(OPCODE, onExtendedOpcode)
  if teleportWindow then teleportWindow:destroy() end
  if teleportButton then teleportButton:destroy() end
  if choiceWindow then choiceWindow:destroy() end
  disconnect(g_game, { onGameEnd = hideWindow })
end

return {
  init      = init,
  terminate = terminate,
  toggle    = toggleWindow
}