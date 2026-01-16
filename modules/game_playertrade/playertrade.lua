tradeWindow = nil

function init()
  g_ui.importStyle('tradewindow')

  connect(g_game, { onOwnTrade = onGameOwnTrade,
                    onCounterTrade = onGameCounterTrade,
                    onCloseTrade = onGameCloseTrade,
                    onGameEnd = onGameCloseTrade })
end

function terminate()
  disconnect(g_game, { onOwnTrade = onGameOwnTrade,
                       onCounterTrade = onGameCounterTrade,
                       onCloseTrade = onGameCloseTrade,
                       onGameEnd = onGameCloseTrade })

  if tradeWindow then
    tradeWindow:destroy()
  end
end

local function getFrame(v)
  if v >= 20000000 then
      return '/images/rarity/rarity_transcendent'
  elseif v >= 10000000 then 
      return '/images/rarity/rarity_abyssal'
  elseif v >= 5000000 then
      return '/images/rarity/rarity_eternal'
  elseif v >= 2000000 then
      return '/images/rarity/rarity_chaos'
  elseif v >= 1000000 then
      return '/images/rarity/rarity_mythic'
  elseif v >= 300000 then
      return '/images/rarity/rarity_exotic'
  elseif v >= 120000 then
      return '/images/rarity/rarity_legendary'
  elseif v >= 50000 then
      return '/images/rarity/rarity_epic'
  elseif v >= 10000 then
      return '/images/rarity/rarity_rare'
  elseif v >= 1000 then
      return '/images/rarity/rarity_uncommon'
  else
      return '/images/rarity/item'
  end
end

local ItemsTable = require("items_table_trade")

local function setFrames()
  if not tradeWindow then return end

  local ownTradeContainer = tradeWindow:recursiveGetChildById('ownTradeContainer')
  local counterTradeContainer = tradeWindow:recursiveGetChildById('counterTradeContainer')
  
  local containers = {}
  if ownTradeContainer then
    table.insert(containers, ownTradeContainer)
  end
  if counterTradeContainer then
    table.insert(containers, counterTradeContainer)
  end
  
  for _, container in ipairs(containers) do
    for _, child in ipairs(container:getChildren()) do
      local item = child:getItem()
      if item then
        local itemId = item:getId()
        local tradeItem = Item.create(itemId)
        local itemName = tradeItem and tradeItem:getMarketData().name:lower() or nil
        if itemName then
          local itemPrice = ItemsTable[itemName]
          if itemPrice then
            local frame = getFrame(itemPrice)
            child:setImageSource(frame)
          else
            child:setImageSource('/images/rarity/item')
          end
        else
          child:setImageSource('/images/rarity/item')
        end
      else
        child:setImageSource('/images/rarity/item')
      end
    end
  end
end

function createTrade()
  tradeWindow = g_ui.createWidget('TradeWindow', modules.game_interface.getRightPanel())
  tradeWindow.onClose = function()
    g_game.rejectTrade()
    tradeWindow:hide()
  end
  tradeWindow:setup()
end

function fillTrade(name, items, counter)
  if not tradeWindow then
    createTrade()
  end

  local tradeItemWidget = tradeWindow:getChildById('tradeItem')
  tradeItemWidget:setItemId(items[1]:getId())

  local tradeContainer
  local label
  local countLabel
  if counter then
    tradeContainer = tradeWindow:recursiveGetChildById('counterTradeContainer')
    label = tradeWindow:recursiveGetChildById('counterTradeLabel')
    countLabel = tradeWindow:recursiveGetChildById('counterTradeCountLabel')
    tradeWindow:recursiveGetChildById('acceptButton'):enable()
  else
    tradeContainer = tradeWindow:recursiveGetChildById('ownTradeContainer')
    label = tradeWindow:recursiveGetChildById('ownTradeLabel')
    countLabel = tradeWindow:recursiveGetChildById('ownTradeCountLabel')
  end
  label:setText(name)
  countLabel:setText(tr("Items") .. ": " .. #items)
  

  for index,item in ipairs(items) do
    local itemWidget = g_ui.createWidget('Item', tradeContainer)
    itemWidget:setItem(item)
    itemWidget:setVirtual(true)
    itemWidget:setMargin(0)
    itemWidget.onClick = function()
      g_game.inspectTrade(counter, index-1)
    end
  end
  setFrames()
end

function onGameOwnTrade(name, items)
  fillTrade(name, items, false)
end

function onGameCounterTrade(name, items)
  fillTrade(name, items, true)
end

function onGameCloseTrade()
  if tradeWindow then
    tradeWindow:destroy()
    tradeWindow = nil
  end
end
