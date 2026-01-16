local CODE = 91

local window = nil
local craftPanel = nil
local itemsList = nil
local selectedCategory = nil
local selectedCraftId = nil
local Crafts = {herbalist = {}, woodcutting = {}, mining = {}, generalcrafting = {}, armorsmith = {}, weaponsmith = {}, jewelsmith = {}}
local money = 0
local fetchLimit = 10

function init()
  connect(
    g_game,
    {
      onGameStart = create,
      onGameEnd = destroy
    }
  )
  ProtocolGame.registerExtendedOpcode(CODE, onExtendedOpcode)
  selectedCraftId = nil
  if g_game.isOnline() then
    create()
  end
end

function terminate()
  disconnect(
    g_game,
    {
      onGameStart = create,
      onGameEnd = destroy
    }
  )
  ProtocolGame.unregisterExtendedOpcode(CODE, onExtendedOpcode)
  destroy()
end

function create()
  if window then
    return
  end
  selectedCategory = "herbalist"
  selectedCraftId = 1 
  window = g_ui.displayUI("crafting")
  window:hide()
  craftPanel = window:getChildById("craftPanel")
  itemsList = window:getChildById("itemsList")
  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(CODE, json.encode({
      action = "fetch",
      data = {
        category = selectedCategory or "herbalist",
        page = 1
      }
    }))
  end
end

function destroy()
  if window then
    craftPanel = nil
    itemsList = nil
    selectedCategory = nil
    selectedCraftId = nil
    Crafts = {herbalist = {}, woodcutting = {}, mining = {}, generalcrafting = {}, armorsmith = {}, weaponsmith = {}, jewelsmith = {}}
    window:destroy()
    window = nil
  end
end

function requestCraftingPage(page)
  if selectedCategory then
    local protocolGame = g_game.getProtocolGame()
    if protocolGame then
      protocolGame:sendExtendedOpcode(CODE, json.encode({
        action = "fetch",
        data = {
          category = selectedCategory,
          page = page
        }
      }))
    else
      print("[Crafting] ProtocolGame is nil")
    end
  else
    print("[Crafting] No category selected")
  end
end

function displayCraftingPage(currentPage, totalPages)
  itemsList:destroyChildren()

  local crafts = Crafts[selectedCategory] or {}
  for i, craft in ipairs(crafts) do
    local widget = g_ui.createWidget("ItemListItem", itemsList)
    widget:setId(i)
    widget:getChildById("item"):setItemId(craft.clientId)
    widget:getChildById("name"):setText(craft.name)
    widget:getChildById("level"):setText("Crafting Level " .. craft.level)
    if i == 1 then
      widget:focus()
    end
  end

  if #crafts > 0 then
    selectedCraftId = (currentPage - 1) * fetchLimit + 1
    selectItem(1)
  else
    selectedCraftId = nil
  end

  local pagination = window:getChildById("pagination")
  if pagination then
    local prevButton = pagination:getChildById("prevPageButton")
    local pageLabel = pagination:getChildById("pageLabel")
    local nextButton = pagination:getChildById("nextPageButton")

    if pageLabel then
      pageLabel:setText(string.format("Page %d/%d", currentPage, totalPages))
    end

    if prevButton then
      prevButton:setEnabled(currentPage > 1)
      prevButton.onClick = function()
        if currentPage > 1 then
          requestCraftingPage(currentPage - 1)
        end
      end
    end

    if nextButton then
      nextButton:setEnabled(currentPage < totalPages)
      nextButton.onClick = function()
        if currentPage < totalPages then
          requestCraftingPage(currentPage + 1)
        end
      end
    end
  end
end

local chunkedMessages = {} 

function onExtendedOpcode(protocol, opcode, buffer)
  if opcode ~= CODE then return end
  local success, parsed = pcall(function() return json.decode(buffer) end)
  if not success then
    g_logger.error("[Crafting] Invalid JSON payload received: " .. tostring(buffer))
    return
  end

  local action = parsed.action
  if action == "chunkedFetch" then
    local cd = parsed.chunkData
    if not cd or not cd.msgID or not cd.index or not cd.count or not cd.payload then
      g_logger.error("[Crafting] Invalid chunk fields in buffer: " .. tostring(buffer))
      return
    end

    if not chunkedMessages[cd.msgID] then
      chunkedMessages[cd.msgID] = {
        totalChunks = cd.count,
        chunksArrived = 0,
        chunks = {}
      }
    end

    local msgInfo = chunkedMessages[cd.msgID]
    msgInfo.chunksArrived = msgInfo.chunksArrived + 1
    msgInfo.chunks[cd.index] = cd.payload

    if msgInfo.chunksArrived == msgInfo.totalChunks then
      local finalString = table.concat(msgInfo.chunks)
      chunkedMessages[cd.msgID] = nil

      local ok2, bigData = pcall(function() return json.decode(finalString) end)
      if not ok2 or not bigData or not bigData.action then
        g_logger.error("[Crafting] Could not decode reassembled JSON for msgID=" .. cd.msgID)
        return
      end
      action = bigData.action
      parsed = bigData
    else
      return
    end
  end

  local data = parsed.data

  if action == "fetch" then
    if not data or not data.category or not data.crafts then
      g_logger.error("[Crafting] Invalid fetch data: " .. tostring(buffer))
      return
    end
    Crafts[data.category] = data.crafts
    local currentPage = data.page or 1
    local totalPages = data.totalPages or 1
    if selectedCategory == data.category then
      displayCraftingPage(currentPage, totalPages)
    end
  elseif action == "materials" then
    if not data.category or not data.materials then
        g_logger.error("[Crafting] Invalid materials data received")
        return
    end
    local materials = data.materials
    for i, matArray in ipairs(materials) do
        local craft = Crafts[data.category] and Crafts[data.category][i]
        if craft then
            for j, materialData in ipairs(matArray) do
                if craft.materials[j] then
                    craft.materials[j].player = materialData.player
                    local materialWidget = craftPanel:getChildById("material" .. j)
                    local countWidget = craftPanel:getChildById("count" .. j)
                    if materialWidget and countWidget then
                        countWidget:setText(materialData.player .. "\n" .. craft.materials[j].count)
                        countWidget:setColor(
                            materialData.player >= craft.materials[j].count and "#FFFFFF" or "#FF0000"
                        )
                    end
                end
            end
        end
    end
  elseif action == "money" then
    if data then
      money = tonumber(data) or 0
      if craftPanel then
        craftPanel:recursiveGetChildById("playerMoney"):setText(comma_value(money))
      end
    else
      g_logger.error("[Crafting] Money action received without valid data")
    end
  elseif action == "show" then
    if data and data.category then
      show(data.category)
    else
      g_logger.error("[Crafting] 'show' action received without valid category")
    end
  elseif action == "craft" then
    for i = 1, 6 do
      local materialWidget = craftPanel:getChildById("craftLine" .. i)
        materialWidget:setImageSource("/images/crafting/craft_line" .. i .. "on")
        scheduleEvent(
          function()
            materialWidget:setImageSource("/images/crafting/craft_line" .. (i == 2 and 5 or i))
          end,
          850
        )
      end
      local button = craftPanel:getChildById("craftButton")
      button:disable()
      scheduleEvent(
        function()
          button:enable()
        end,
        860
      )
  end
end

function onSearch()
  scheduleEvent(
    function()
      local searchInput = window:recursiveGetChildById("searchInput")
      local text = searchInput:getText():lower()
      if text:len() >= 1 then
        local children = itemsList:getChildCount()
        for i = children, 1, -1 do
          local child = itemsList:getChildByIndex(i)
          local name = child:getChildById("name"):getText():lower()
          if name:find(text) then
            child:show()
            child:focus()
            selectItem(i)
          else
            child:hide()
          end
        end
      else
        local children = itemsList:getChildCount()
        for i = children, 1, -1 do
          local child = itemsList:getChildByIndex(i)
          child:show()
          child:focus()
          selectItem(i)
        end
      end
    end,
    25
  )
end

function selectCategory(category)
  if not category then
    g_logger.error("[Crafting] Invalid category selected.")
    return
  end

  selectedCategory = category
  selectedCraftId = nil

  requestCraftingPage(1)
end
function selectItem(id)
  resetUI()

  local craftId = tonumber(id) or 1
  if selectedCraftId == nil then
    selectedCraftId = 1
  end
  local currentPage = math.floor((selectedCraftId - 1) / fetchLimit) + 1
  local offset = (currentPage - 1) * fetchLimit
  local correctedId = craftId + offset
  selectedCraftId = correctedId

  if not selectedCategory or not Crafts[selectedCategory] or not Crafts[selectedCategory][craftId] then
    return
  end

  local craft = Crafts[selectedCategory][craftId]

  local storageLabel = craftPanel:getChildById("storageStatus")
  local storageTextLabel = craftPanel:getChildById("storageText")

  if craft.storage and craft.storage > 0 then
    if craft.playerStorage == 1 then
      storageLabel:setText("Recipe Unlocked")
      storageLabel:setColor("#00FF00")
    else
      storageLabel:setText("You need to learn this recipe")
      storageLabel:setColor("#FF0000")
    end
  else
    storageLabel:setText("No need to learn the recipe")
    storageLabel:setColor("#FFFFFF")
  end

  if craft.storageText and craft.storageText ~= "" then
    storageTextLabel:setText(craft.storageText)
  else
    storageTextLabel:setText("")
  end

  for i = 1, #craft.materials do
    local material = craft.materials[i]
    local materialWidget = craftPanel:getChildById("material" .. i)
    materialWidget:setItemId(material.clientId)
    local count = craftPanel:getChildById("count" .. i)
    count:setText(material.player .. "\n" .. material.count)
    if material.player >= material.count then
      count:setColor("#FFFFFF")
    else
      count:setColor("#FF0000")
    end
  end

  local outcome = craftPanel:getChildById("craftOutcome")
  outcome:setItemId(craft.clientId)
  outcome:setItemCount(craft.count)
  craftPanel:recursiveGetChildById("totalCost"):setText(comma_value(craft.cost))
end

function resetUI()
  for i = 1, 6 do
    local materialWidget = craftPanel:getChildById("material" .. i)
    materialWidget:setItem(nil)
    craftPanel:getChildById("count" .. i):setText("")
  end
  local outcome = craftPanel:getChildById("craftOutcome")
  outcome:setItem(nil)
  outcome:setItemCount(0)
  craftPanel:recursiveGetChildById("totalCost"):setText("0")
end

function craftItem()
  if selectedCategory and selectedCraftId then
    local protocolGame = g_game.getProtocolGame()
    if protocolGame then
      protocolGame:sendExtendedOpcode(CODE, json.encode({
        action = "craft",
        data = {
          category = selectedCategory,
          craftId = selectedCraftId
        }
      }))
    else
      print("[Crafting] ProtocolGame is nil")
    end
  else
    print("[Crafting] No category or craft ID selected")
  end
end

function updateTabsUI()
  local categoriesPanel = window:getChildById("categories")
  if not categoriesPanel then
    g_logger.error("[Crafting] Categories panel not found in the UI.")
    return
  end

  for _, child in pairs(categoriesPanel:getChildren()) do
    if child:getId() == (selectedCategory .. "Cat") then
      child:setOpacity(1.0)
      child:setPhantom(false)
    else
      child:setOpacity(0.0)
      child:setPhantom(true)
    end
  end
end



function show(category)
  if not window then
    return
  end

  selectedCategory = category
  selectedCraftId = 1

  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(CODE, json.encode({
      action = "fetch",
      data = {
        category = selectedCategory,
        page = 1
      }
    }))
  end

  window:show()
  window:raise()
  window:focus()
  updateTabsUI()
end


function hide()
  if not window then
    return
  end
  window:hide()
end

function comma_value(amount)
  local formatted = amount
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1.%2")
    if (k == 0) then
      break
    end
  end
  return formatted
end