local UPGRADES_CODE = 181
local upgradesWindow = nil
local upgradesOffersGrid = nil
local upgradesMsgWindow = nil
local upgradesButton = nil

local upgradeCategories = nil
local upgradeOffers = {}

local selectedUpgradeOffer = nil

function init()
  connect(
    g_game,
    {
      onGameStart = createUpgradesWindow,
      onGameEnd = destroyUpgradesWindow
    }
  )

  ProtocolGame.registerExtendedOpcode(UPGRADES_CODE, onUpgradesExtendedOpcode)

  if g_game.isOnline() then
    createUpgradesWindow()
  end
end

function terminate()
  disconnect(
    g_game,
    {
      onGameStart = createUpgradesWindow,
      onGameEnd = destroyUpgradesWindow
    }
  )

  ProtocolGame.unregisterExtendedOpcode(UPGRADES_CODE, onUpgradesExtendedOpcode)

  destroyUpgradesWindow()
end

function onUpgradesExtendedOpcode(protocol, code, buffer)
  local json_status, json_data =
    pcall(
    function()
      return json.decode(buffer)
    end
  )
  if not json_status then
    g_logger.error("UPGRADES json error: " .. json_data)
    return false
  end
  local action = json_data["action"]
  local data = json_data["data"]
  if not action or not data then
    return false
  end

  if action == "fetchBase" then
    onUpgradesFetchBase(data)
  elseif action == "fetchOffers" then
    onUpgradesFetchOffers(data)
  elseif action == "points" then
    onUpgradesUpdatePoints(data)
  elseif action == "msg" then
    onUpgradesMsg(data)
  elseif action == "upgrade_points" then
    onUpgradesUpdatePoints(data)
  elseif action == "refresh_offers" then
    onUpgradesRefreshOffers(data)
  end
end

function createUpgradesWindow()
  if upgradesWindow then
    return
  end
  upgradesWindow = g_ui.displayUI("upgrades")
  upgradesWindow:hide()

  upgradesButton = modules.client_topmenu.addRightGameToggleButton("upgradesButton", tr("Upgrades"), "/images/topbuttons/charupgrades", toggleUpgrades, true)

  connect(upgradesWindow:getChildById("categories"), {onChildFocusChange = changeUpgradeCategory})
  connect(upgradesWindow:getChildById("offers"), {onChildFocusChange = upgradeOfferFocus})

  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(UPGRADES_CODE, json.encode({action = "fetch", data = {}}))
  end
end

function destroyUpgradesWindow()
  if upgradesButton then
    upgradesButton:destroy()
    upgradesButton = nil
  end

  if upgradesWindow then
    disconnect(upgradesWindow:getChildById("categories"), {onChildFocusChange = changeUpgradeCategory})
    disconnect(upgradesWindow:getChildById("offers"), {onChildFocusChange = upgradeOfferFocus})
    upgradesOffersGrid = nil
    upgradesWindow:destroy()
    upgradesWindow = nil
  end

  if upgradesMsgWindow then
    upgradesMsgWindow:destroy()
    upgradesMsgWindow = nil
  end
end

function onUpgradesFetchBase(data)
  upgradeCategories = data.categories
  for i = 1, #upgradeCategories do
    addUpgradeCategory(upgradeCategories[i], i == 1)
  end
end

function onUpgradesFetchOffers(data)
  upgradeOffers[data.category] = data.offers

  for i, offer in ipairs(data.offers) do
    if offer.imageFile then
    elseif offer.clientId == 0 and offer.upgradeType then
      offer.imageFile = offer.upgradeType
    end
  end

  local currentCategory = nil
  if upgradesWindow and upgradesWindow:isVisible() then
    local categoriesPanel = upgradesWindow:getChildById("categories")
    if categoriesPanel and categoriesPanel:getFocusedChild() then
      currentCategory = categoriesPanel:getFocusedChild():getId()
    end
  end

  --- if data.category == "Skills" and not upgradesOffersGrid then
  if (data.category == "Skills" or data.category == "Elements" or data.category == "Others") and not upgradesOffersGrid then
  upgradesOffersGrid = upgradesWindow:recursiveGetChildById("offers")
  addUpgradeOffers(upgradeOffers[data.category])
    upgradesWindow:getChildById("categories"):getChildByIndex(1):focus()
  elseif data.category == currentCategory and upgradesOffersGrid then
    upgradesOffersGrid:destroyChildren()
    addUpgradeOffers(upgradeOffers[currentCategory])
  end
end

function onUpgradesUpdatePoints(data)
  if not upgradesWindow then return end

  local pointsWidget = upgradesWindow:recursiveGetChildById("points")
  if not pointsWidget then
    print("[UPGRADES] Could not find 'points' label.")
    return
  end

  if type(data) ~= "table" or not data.total then
    print("[UPGRADES] Invalid data format:", data)
    return
  end

  local total = tonumber(data.total or 0)
  local spendable = tonumber(data.spendable or 0)
  local pointsValue = string.format("%s points", comma_value(spendable), comma_value(total))

  pointsWidget:setText(pointsValue)


  if spendable <= 0 then
    pointsWidget:setColor("#FF4444") -- red
    pointsWidget:setWidth(150)
    pointsWidget:setHeight(20)
  elseif spendable < total then
    pointsWidget:setColor("#FFFF00") -- yellow
    pointsWidget:setWidth(150)
    pointsWidget:setHeight(20)
  else
    pointsWidget:setColor("#28DB00") -- green
    pointsWidget:setWidth(150)
    pointsWidget:setHeight(20)
  end

  local pointsIcon = upgradesWindow:recursiveGetChildById("points")
  if not pointsIcon then
    local infoPanel = upgradesWindow:getChildById("infoPanel")
    pointsIcon = g_ui.createWidget("UIItem", infoPanel)
    pointsIcon:setId("pointsIcon")
    pointsIcon:setItemId(3249)
    pointsIcon:setSize({width = 32, height = 32})
    pointsIcon:setMarginLeft(5)
    pointsIcon:setMarginTop(20)
  end
end

function purchaseUpgrade()
  if not selectedUpgradeOffer then
    displayInfoBox("Error", "Something went wrong, make sure to select category and upgrade.")
    return
  end

  if selectedUpgradeOffer.maxed or selectedUpgradeOffer.disabled then
    displayInfoBox("Error", "This upgrade is already at max level.")
    return
  end

  local currentCategory = upgradesWindow:getChildById("categories"):getFocusedChild():getId()
  selectedUpgradeOffer.savedCategory = currentCategory

  local protocolGame = g_game.getProtocolGame()
  if protocolGame then
    protocolGame:sendExtendedOpcode(UPGRADES_CODE, json.encode({action = "purchase", data = selectedUpgradeOffer}))
  end
end

function onUpgradesMsg(data)
  local t = data.type
  local txt = data.msg


  if t == "error" then
    displayInfoBox("Error", txt)

    upgradesWindow:getChildById("purchaseButton"):enable()
    return
  elseif t == "info" then
    displayInfoBox("Info", txt)

    upgradesWindow:getChildById("purchaseButton"):disable()
    upgradesWindow:getChildById("offers"):focusChild(nil)

    if txt:find("You've purchased") then
      local currentCategory = upgradesWindow
        :getChildById("categories")
        :getFocusedChild()
        :getId()
      local proto = g_game.getProtocolGame()
      if proto then
        proto:sendExtendedOpcode(UPGRADES_CODE, json.encode({
          action = "fetch_category",
          data   = { category = currentCategory }
        }))
      end
    end

    if data.close then
      scheduleEvent(hideUpgradesWindow, 500)
    end
  end
end


function changeUpgradeCategory(widget, newCategory)
  if not newCategory then
    return
  end

  local id = newCategory:getId()

  if not upgradesOffersGrid then
    upgradesOffersGrid = upgradesWindow:recursiveGetChildById("offers")
  end

  upgradesOffersGrid:destroyChildren()
  if upgradeOffers[id] then
    addUpgradeOffers(upgradeOffers[id])
  else
    local protocolGame = g_game.getProtocolGame()
    if protocolGame then
      protocolGame:sendExtendedOpcode(UPGRADES_CODE, json.encode({
        action = "fetch_category", 
        data = {category = id}
      }))
    end
  end

  local category = nil
  for i = 1, #upgradeCategories do
    if upgradeCategories[i].title == id then
      category = upgradeCategories[i]
      break
    end
  end

  if category then
    updateUpgradesTopPanel(category)
    upgradesWindow:getChildById("purchaseButton"):disable()
    upgradesWindow:getChildById("search"):setText("")
  end
end

function upgradeOfferFocus(widget, offerWidget)
  -- reset level label colors
  for i = 1, upgradesOffersGrid:getChildCount() do
    local lvl = upgradesOffersGrid:getChildByIndex(i):getChildById("levelLabel")
    if lvl then lvl:setColor("#FFFFFF") end
  end

  local purchaseBtn = upgradesWindow and upgradesWindow:getChildById("purchaseButton")
  selectedUpgradeOffer = nil

  if not offerWidget then
    if purchaseBtn then purchaseBtn:disable() end
    return
  end

  -- highlight
  offerWidget:getChildById("levelLabel"):setColor("#FFFF00")

  -- if offer is maxed or disabled, do not allow selecting it
  local offerData = offerWidget.offerData or {}
  if offerData.maxed or offerData.disabled then
    if purchaseBtn then purchaseBtn:disable() end
    return
  end

  -- extract normal selection data
  local title = offerWidget:getChildById("offerNameHidden"):getText()
  local rawPrice = offerWidget:getChildById("offerPrice"):getText():match("([%d,]+)")
  local cleanedPrice = rawPrice and rawPrice:gsub(",", "") or "0"
  local price = tonumber(cleanedPrice) or 0 
  local coinCost = offerWidget.coinCost or { itemId = 0, count = 0 }

  selectedUpgradeOffer = {
    type = "upgrade",
    category = upgradesWindow
                  :getChildById("categories")
                  :getFocusedChild()
                  :getChildById("name")
                  :getText(),
    title = title,
    price = price,
    coinCost = coinCost,
    upgradeType = offerWidget:getChildById("upgradeType"):getText(),
    storageKey = offerWidget.storageKey,
    maxed = offerData.maxed,
    disabled = offerData.disabled
  }

  if purchaseBtn then purchaseBtn:enable() end
end

function addUpgradeCategory(data, first)
  local category = g_ui.createWidget("ShopCategory", upgradesWindow:getChildById("categories"))
  category:setId(data.title)
  category:getChildById("name"):setText(data.title)

  if first then
    updateUpgradesTopPanel(data)
  end
end

function addUpgradeOffers(offerData)

  if not offerData or type(offerData) ~= "table" then
    return
  end

  if upgradesOffersGrid:getChildCount() > 0 then
    upgradesOffersGrid:destroyChildren()
  end

  for i = 1, #offerData do
    local offer = offerData[i]
    local panel = g_ui.createWidget("OfferWidget")
    panel.offerData = offer
    panel.storageKey = offer.storageKey
    panel:setTooltip(offer.description)
    panel.coinCost = offer.coinCost or { itemId = 0, count = 0 }
    local nameHidden = panel:recursiveGetChildById("offerNameHidden")
    local upgradeType = g_ui.createWidget("Label", panel)
    upgradeType:setId("upgradeType")
    upgradeType:setText(offer.upgradeType)
    upgradeType:hide()

    local levelLabel = panel:recursiveGetChildById("levelLabel")
    local currentLevel = offer.currentLevel or 0
    levelLabel:setText("Level " .. currentLevel)

    local baseName = offer.title:match("(.+) %(Level")
    if baseName and baseName:len() > 20 then
      local shorter = baseName:sub(1, 20) .. "..."
      panel:setText(shorter)
    else
      panel:setText(baseName or offer.title)
    end

    nameHidden:setText(offer.title)

    local priceLabel = panel:recursiveGetChildById("offerPrice")
    if offer.maxed or offer.disabled then
      priceLabel:setText("Max Level")
      priceLabel:setColor("#F44336")
    else
      local price = comma_value(offer.price)
      priceLabel:setText(string.format(priceLabel.baseText, price))
    end

    local offerTypePanel = panel:getChildById("offerTypePanel")

    local coinIcon = panel:getChildById("coinIcon")
    if coinIcon and offer.coinText and offer.coinText ~= "" then
      coinIcon:setText( offer.coinText )
    end
    if offer.imageFile then
      local offerIcon = g_ui.createWidget("OfferIconImage", offerTypePanel)
      offerIcon:setId("offerIcon")
      offerIcon:setImageSource("/modules/game_upgrades/ui/" .. offer.imageFile .. ".png")
      offerIcon:setPhantom(true)
    elseif offer.type == "upgrade" then
      local offerIcon = g_ui.createWidget("OfferIconItem", offerTypePanel)
      offerIcon:setItemId(offer.clientId)
      if offer.count and offer.count > 0 then
        offerIcon:setItemCount(offer.count)
      end
    elseif offer.type == "shopItem" then
      local iconClientId = offer.clientId or 0
      if iconClientId == 0 and offer.reward and offer.reward.itemId and offer.reward.itemId > 0 then
        iconClientId = ItemType(offer.reward.itemId):getClientId()
      end

      if iconClientId > 0 then
        local tierIcon = g_ui.createWidget("OfferIconItem", offerTypePanel)
        tierIcon:setItemId(iconClientId)
        if offer.reward and offer.reward.count and offer.reward.count > 1 then
          tierIcon:setItemCount(offer.reward.count)
        end
        tierIcon:setPhantom(true)
        tierIcon:setTooltip("")
      end
    end

    upgradesOffersGrid:addChild(panel)
  end
  selectedUpgradeOffer = nil
  upgradesWindow:getChildById("purchaseButton"):disable()
end

function updateUpgradesTopPanel(data)
  local topPanel = upgradesWindow:getChildById("topPanel")
  local categoryItemBg = topPanel:getChildById("categoryItemBg")
  categoryItemBg:destroyChildren()
  if data.iconType == "sprite" then
    local spriteIcon = g_ui.createWidget("CategoryIconSprite", categoryItemBg)
    spriteIcon:setSpriteId(data.iconData)
  elseif data.iconType == "item" then
    local spriteIcon = g_ui.createWidget("CategoryIconItem", categoryItemBg)
    spriteIcon:setItemId(data.iconData)
  elseif data.iconType == "creature" then
    local spriteIcon = g_ui.createWidget("CategoryIconCreature", categoryItemBg)
    spriteIcon:setOutfit(data.iconData)
  end

  topPanel:getChildById("selectedCategory"):setText(data.title)
  topPanel:getChildById("categoryDescription"):setText(data.description)
end

function onUpgradeSearch()
  scheduleEvent(
    function()
      local searchWidget = upgradesWindow:getChildById("search")
      local text = searchWidget:getText()
      if text:len() >= 1 then
        local children = upgradesOffersGrid:getChildCount()
        for i = 1, children do
          local child = upgradesOffersGrid:getChildByIndex(i)
          local offerName = child:getChildById("offerNameHidden"):getText():lower()
          if offerName:find(text) then
            child:show()
          else
            child:hide()
          end
        end
      else
        local children = upgradesOffersGrid:getChildCount()
        for i = 1, children do
          local child = upgradesOffersGrid:getChildByIndex(i)
          child:show()
        end
      end
    end,
    50
  )
end

function toggleUpgrades()
  if not upgradesWindow then
    return
  end
  if upgradesWindow:isVisible() then
    return hideUpgradesWindow()
  end
  showUpgradesWindow()
end

function showUpgradesWindow()
  if not upgradesWindow or not upgradesButton then
    return
  end
  local categoriesPanel = upgradesWindow:getChildById("categories")
  if categoriesPanel and categoriesPanel:getChildCount() > 0 then
    categoriesPanel:getChildByIndex(1):focus()
    local focusedChild = categoriesPanel:getFocusedChild()
    if focusedChild then
      local categoryId = focusedChild:getId()
      local protocolGame = g_game.getProtocolGame()
      if protocolGame then
        protocolGame:sendExtendedOpcode(UPGRADES_CODE, json.encode({
          action = "fetch_category", 
          data = {category = categoryId}
        }))
      end
    end
  end
  upgradesWindow:show()
  upgradesWindow:raise()
  upgradesWindow:focus()
end

function hideUpgradesWindow()
  if not upgradesWindow then
    return
  end
  upgradesWindow:hide()
end

function onUpgradesRefreshOffers(data)
  upgradeOffers[data.category] = data.offers
  for i, offer in ipairs(data.offers) do
    if offer.imageFile then
    elseif offer.clientId == 0 and offer.upgradeType then
      offer.imageFile = offer.upgradeType
    end
  end
  local currentCategory = nil
  if upgradesWindow and upgradesWindow:isVisible() then
    local categoriesPanel = upgradesWindow:getChildById("categories")
    if categoriesPanel and categoriesPanel:getFocusedChild() then
      currentCategory = categoriesPanel:getFocusedChild():getId()
      if not upgradesOffersGrid then
        upgradesOffersGrid = upgradesWindow:recursiveGetChildById("offers")
      end
      if data.category == currentCategory and upgradesOffersGrid then
        upgradesOffersGrid:destroyChildren()
        addUpgradeOffers(upgradeOffers[currentCategory])
        selectedUpgradeOffer = nil
        upgradesWindow:getChildById("purchaseButton"):disable()
      end
    end
  end
end

function comma_value(n)
  local left, num, right = string.match(n, "^([^%d]*%d)(%d*)(.-)$")
  return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
end 