MessageSettings = {
  none            = {},
  consoleRed      = { color = TextColors.red,    consoleTab='Default' },
  consoleOrange   = { color = TextColors.orange, consoleTab='Default' },
  consoleBlue     = { color = TextColors.blue,   consoleTab='Default' },
  centerRed       = { color = TextColors.red,    consoleTab='Server Log', screenTarget='lowCenterLabel' },
  centerGreen     = { color = TextColors.green,  consoleTab='Server Log', screenTarget='highCenterLabel',   consoleOption='showInfoMessagesInConsole' },
  centerWhite     = { color = TextColors.white,  consoleTab='Server Log', screenTarget='middleCenterLabel', consoleOption='showEventMessagesInConsole' },
  bottomWhite     = { color = TextColors.white,  consoleTab='Server Log', screenTarget='statusLabel',       consoleOption='showEventMessagesInConsole' },
  status          = { color = TextColors.white,  consoleTab='Server Log', screenTarget='statusLabel',       consoleOption='showStatusMessagesInConsole' },
  statusSmall     = { color = TextColors.white,                           screenTarget='statusLabel' },
  private         = { color = TextColors.lightblue,                       screenTarget='privateLabel' },
  loot = { color = TextColors.white,  screenTarget = 'highCenterLabel',  consoleOption = 'showInfoMessagesInConsole'}
}

MessageTypes = {
  [MessageModes.MonsterSay] = MessageSettings.consoleOrange,
  [MessageModes.MonsterYell] = MessageSettings.consoleOrange,
  [MessageModes.BarkLow] = MessageSettings.consoleOrange,
  [MessageModes.BarkLoud] = MessageSettings.consoleOrange,
  [MessageModes.Failure] = MessageSettings.statusSmall,
  [MessageModes.Login] = MessageSettings.bottomWhite,
  [MessageModes.Game] = MessageSettings.centerWhite,
  [MessageModes.Status] = MessageSettings.status,
  [MessageModes.Warning] = MessageSettings.centerRed,
  [MessageModes.Look] = MessageSettings.centerGreen,
  [MessageModes.Loot] = MessageSettings.loot,
  [MessageModes.Red] = MessageSettings.consoleRed,
  [MessageModes.Blue] = MessageSettings.consoleBlue,
  [MessageModes.PrivateFrom] = MessageSettings.consoleBlue,

  [MessageModes.GamemasterBroadcast] = MessageSettings.consoleRed,

  [MessageModes.DamageDealed] = MessageSettings.status,
  [MessageModes.DamageReceived] = MessageSettings.status,
  [MessageModes.Heal] = MessageSettings.status,
  [MessageModes.Exp] = MessageSettings.status,

  [MessageModes.DamageOthers] = MessageSettings.none,
  [MessageModes.HealOthers] = MessageSettings.none,
  [MessageModes.ExpOthers] = MessageSettings.none,

  [MessageModes.TradeNpc] = MessageSettings.centerWhite,
  [MessageModes.Guild] = MessageSettings.centerWhite,
  [MessageModes.Party] = MessageSettings.centerGreen,
  [MessageModes.PartyManagement] = MessageSettings.centerWhite,
  [MessageModes.TutorialHint] = MessageSettings.centerWhite,
  [MessageModes.BeyondLast] = MessageSettings.centerWhite,
  [MessageModes.Report] = MessageSettings.consoleRed,
  [MessageModes.HotkeyUse] = MessageSettings.centerGreen,

  [254] = MessageSettings.private
}

messagesPanel = nil

local rarityColors = {
  common = "#AAAAAA", -- Common (Gray)
  uncommon = "#1EFF00", -- Uncommon (Green)
  rare = "#0088FF", -- Rare (Blue)
  epic = "#870DFF", -- Epic (Purple)
  legendary = "#F5891D", -- Legendary (Orange)
  exotic = "#FA5025", -- Exotic (Vivid Orange)
  mythic = "#F0E229", -- Mythic (Golden Yellow)
  chaos = "#990000", -- Chaos (Dark Red)
  eternal = "#00CFFF", -- Eternal (Cyan)
  divine = "#FFD700", -- Divine (Bright Gold)
  phantasmal = "#A600FF", -- Phantasmal (Deep Purple)
  celestial = "#7DFFFA", -- Celestial (Light Aqua)
  cosmic = "#FF4500", -- Cosmic (Fiery Red-Orange)
  abyssal = "#2b68b3", -- Abyssal (Blue Indigo)
  transcendent = "#FF0000" -- Transcendent (Brutal Red)
}
local listOfValuesByItemId = require("items_loot")

local function stripQty(s)
  -- add the "2x or 5x etc" to the loot string on channel and show color if more than x1
  return (s:gsub("^%s*%d+%s*[%*xX×%-:]%s*", ""))
end

local function getColorForValue(value)
  if value >= 20000000 then
      return rarityColors.transcendent
  elseif value >= 10000000 then
      return rarityColors.abyssal
  elseif value >= 5000000 then
      return rarityColors.eternal
  elseif value >= 2000000 then
      return rarityColors.chaos
  elseif value >= 1000000 then
      return rarityColors.mythic
  elseif value >= 300000 then
      return rarityColors.exotic
  elseif value >= 120000 then
      return rarityColors.legendary
  elseif value >= 50000 then
      return rarityColors.epic
  elseif value >= 10000 then
      return rarityColors.rare
  elseif value >= 1000 then
      return rarityColors.uncommon
  else
      return rarityColors.common
  end
end
local function formatTextWithColorTags(formattedTable)
  local combinedString = ""
  for i=1, #formattedTable, 2 do
    local partText = formattedTable[i]
    local partColor = formattedTable[i+1]
    combinedString = combinedString
                    .. string.format('<color="%s">%s</color>', partColor, partText)
  end
  return combinedString
end
local function normalizeItemName(itemName)
  -- Trim whitespace from the start and end.
  local trimmed = itemName:gsub("^%s*(.-)%s*$", "%1")
  -- Remove a leading article such as "a " or "an "
  trimmed = trimmed:gsub("^(a[n]?)%s+", "")
  -- Look for a rarity prefix in square brackets.
  local prefixFound, nameWithoutPrefix = trimmed:match("^%[(%w+)%]%s*(.+)")
  if prefixFound and nameWithoutPrefix then
    -- Return the prefix (with brackets, for display) and the remainder.
    return string.format("[%s]", prefixFound), nameWithoutPrefix
  end
  return "", trimmed
end
local function applyColorLootMessage(text)
  if not text or text == "" then
    return { text, TextColors.white }
  end
  local formattedText = {}
  local prefix, lootItems = text:match("^(Loot of [^:]+:)(.+)$")
  if not prefix or not lootItems then
    return { text, TextColors.white }
  end
  table.insert(formattedText, prefix)
  table.insert(formattedText, TextColors.white)
  -- Process each comma-separated loot item.
  for itemName, separator in lootItems:gmatch(" ([^,]+)(,?)") do
    -- Normalize: separate out prefix (if any) and base name.
    local rarityPrefix, baseName = normalizeItemName(itemName)
    
    -- Determine the base color from the item's value.
    local lookupName = stripQty(baseName):lower()
    local baseColor = TextColors.white
    local value = listOfValuesByItemId[lookupName]
    if value then
      baseColor = getColorForValue(value) or TextColors.white
    end
    -- If a rarity prefix is found, determine its color;
    -- otherwise, use the base color.
    local prefixColor = baseColor
    if rarityPrefix ~= "" then
      local rarityKey = rarityPrefix:sub(2, -2):lower() -- remove the brackets and convert to lowercase
      prefixColor = rarityColors[rarityKey] or TextColors.white
    end
    -- Build the formatted text:
    if rarityPrefix ~= "" then
      -- Insert the prefix with rarity color:
      table.insert(formattedText, " " .. rarityPrefix)
      table.insert(formattedText, prefixColor)
      -- Then insert a space and the base name with the base color.
      table.insert(formattedText, " " .. baseName)
      table.insert(formattedText, baseColor)
    else
      -- No rarity prefix: use the whole item name in the base color.
      table.insert(formattedText, " " .. itemName)
      table.insert(formattedText, baseColor)
    end
    if separator and separator ~= "" then
      table.insert(formattedText, separator)
      table.insert(formattedText, TextColors.white)
    end
  end
  if #formattedText % 2 ~= 0 then
    return { text, TextColors.white }
  end
  return formattedText
end


function init()
  for messageMode, _ in pairs(MessageTypes) do
    registerMessageMode(messageMode, displayMessage)
  end

  connect(g_game, 'onGameEnd', clearMessages)
  messagesPanel = g_ui.loadUI('textmessage', modules.game_interface.getRootPanel())
end

function terminate()
  for messageMode, _ in pairs(MessageTypes) do
    unregisterMessageMode(messageMode, displayMessage)
  end

  disconnect(g_game, 'onGameEnd', clearMessages)
  clearMessages()
  messagesPanel:destroy()
end

function calculateVisibleTime(text)
  return math.max(#text * 50, 3000)
end

function displayMessage(mode, text)
  if not g_game.isOnline() then return end

  local msgtype = MessageTypes[mode]
  if not msgtype then
    return
  end

  if msgtype == MessageSettings.none then return end

  if msgtype.consoleTab ~= nil and (msgtype.consoleOption == nil or modules.client_options.getOption(msgtype.consoleOption)) then
    modules.game_console.addText(text, msgtype, tr(msgtype.consoleTab))
    --TODO move to game_console
  end

  if msgtype.screenTarget then
    local label = messagesPanel:recursiveGetChildById(msgtype.screenTarget)
    if not label then
      return
  end
  if label.setColoredText and msgtype == MessageSettings.loot then
      local formattedText = applyColorLootMessage(text)
      if type(formattedText) == "table" then
          label:setColoredText(formattedText)
      else
          label:setText(text)
          label:setColor(msgtype.color)
      end
  else
      label:setText(text)
      label:setColor(msgtype.color)
  end
    label:setVisible(true)
    if label.hideEvent then
      removeEvent(label.hideEvent)
  end
    label.hideEvent = scheduleEvent(function() label:setVisible(false) end, calculateVisibleTime(text))
    if mode == MessageModes.Loot then
      local coloredTable = applyColorLootMessage(text)
      if type(coloredTable) == 'table' then
        local colorTagged = formatTextWithColorTags(coloredTable)
        modules.game_console.addText(colorTagged, MessageSettings.status, tr('Loot'))
        return
      end
    end
  end
end

function displayPrivateMessage(text)
  displayMessage(254, text)
end

function displayStatusMessage(text)
  displayMessage(MessageModes.Status, text)
end

function displayFailureMessage(text)
  displayMessage(MessageModes.Failure, text)
end

function displayGameMessage(text)
  displayMessage(MessageModes.Game, text)
end

function displayBroadcastMessage(text)
  displayMessage(MessageModes.Warning, text)
end

function clearMessages()
  for _i,child in pairs(messagesPanel:recursiveGetChildren()) do
    if child:getId():match('Label') then
      child:hide()
      removeEvent(child.hideEvent)
    end
  end
end

function LocalPlayer:onAutoWalkFail(player)
  modules.game_textmessage.displayFailureMessage(tr('There is no way.'))
end
