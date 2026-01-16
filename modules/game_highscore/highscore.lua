local HIGH_OP       = 73
local window, button
local highscoreData = {}
local categoryId, page, pages
local filterIndex   = 1
local showOnlyMe    = false

local filterOptions = {
  { label = "All Vocations", filter = {0,1,2,3,4,5,6,7,8,9,10} },
  { label = "Sorcerer",      filter = {1,5}               },
  { label = "Druid",         filter = {2,6}               },
  { label = "Paladin",       filter = {3,7}               },
  { label = "Knight",        filter = {4,8}               },
  { label = "Illusionist",   filter = {9,10}              },
}

local serverToName = {
  [0]  = "None",
  [1]  = "Sorcerer",   [5]  = "Master Sorcerer",
  [2]  = "Druid",      [6]  = "Elder Druid",
  [3]  = "Paladin",    [7]  = "Royal Paladin",
  [4]  = "Knight",     [8]  = "Elite Knight",
  [9]  = "Illusionist",[10] = "Arch Illusionist",
}

local categories = {
  "Experience",
  "Sword","Axe","Club",
  "Distance","Shielding","Magic","Mining","Fishing", "Woodcutting",
  "Herbalist", "Crafting", "Weaponsmith", "Armorsmith", "Jewelsmith", "Ancestral Points", "Ancestral Ranking"
}
local categoryLabel = {
  "Experience","Skill","Skill","Skill","Skill","Skill","Skill","Skill","Skill","Skill","Skill","Skill","Skill","Skill","Skill", "Ancestral Points", "Ancestral Ranking"
}

local function sendHighscoreRequest(cat, pg, perPage, own)
  local proto = g_game.getProtocolGame()
  if not proto then return end
  local vocs = filterOptions[filterIndex].filter
  local payload = json.encode{
    action         = "request",
    category       = cat,
    vocation       = 0,
    page           = pg,
    entriesPerPage = perPage,
    type           = own  or 0,
    vocations      = vocs,
  }
  proto:sendExtendedOpcode(HIGH_OP, payload)
  if window then
    window.content.next:setEnabled(false)
    window.content.nextLast:setEnabled(false)
    window.content.prev:setEnabled(false)
    window.content.prevLast:setEnabled(false)
  end
end

function onHighscore(protocol, opcode, buffer)
  local ok,msg = pcall(json.decode, buffer)
  if not ok or msg.action ~= "highscore" then return false end
  categoryId, page, pages = msg.category, msg.page, msg.pages
  highscoreData = msg.data or {}
  window.content.filters.categoryBox:setText(categories[categoryId+1])
  window.content.filters.vocationBox:setText(filterOptions[filterIndex].label)
  window.content.experience:setText(categoryLabel[categoryId+1])
  window.content.page:setText(("%d / %d"):format(page, pages))
  createHighscores()
  local f = window.content
  f.next    :setEnabled(page < pages)
  f.nextLast:setEnabled(page < pages)
  f.prev    :setEnabled(page > 1)
  f.prevLast:setEnabled(page > 1)
  return true
end

function createHighscores()
  local container = window.content.data
  container:destroyChildren()
  local me = g_game.getLocalPlayer():getName()
  for i,entry in ipairs(highscoreData) do
    if (not showOnlyMe) or entry.name==me then
      local row = g_ui.createWidget("HighScoreData", container)
	  row.outfit:setOutfit({
		type   = entry.lookType,
		head   = entry.lookHead,
		body   = entry.lookBody,
		legs   = entry.lookLegs,
		feet   = entry.lookFeet,
		addons = entry.lookAddons,
		wings = entry.wingsId,
		aura = entry.auraId,
		shader = entry.shaderId,
	  })
	  row.outfit:setAnimate(true)
      row:setBackgroundColor((i%2==0) and "#ffffff12" or "#00000012")
      row.name:setColor(entry.online==1 and "green" or "red")
      if entry.online==1 then
        row.onClick = function()
          modules.game_inspect.inspect(nil, entry.name, entry.outfit)
        end
      end
      row.rank:setText(entry.rank)
      row.name:setText(entry.name)
      row.voc:setText(serverToName[entry.vocation] or "??")
      row.level:setText(entry.level)
      row.experience:setText(comma_value(entry.experience))
      if entry.name==me then setColorTo(row,"#0095ff") end
      if showOnlyMe then break end
    end
  end
  showOnlyMe = false
end

function create()
  if window then return end
  window = g_ui.displayUI("highscore")

  local vb = window.content.filters.vocationBox
  vb:clearOptions()
  for _,opt in ipairs(filterOptions) do
    vb:addOption(opt.label)
  end
  vb:setCurrentIndex(1)
  vb.onOptionChange = function(self)
    filterIndex = self.currentIndex
    sendHighscoreRequest(categoryId or 0, 1, 10, 0)
  end

  local cb = window.content.filters.categoryBox
  cb:clearOptions()
  for _,cat in ipairs(categories) do cb:addOption(cat) end
  cb:setCurrentIndex(1)
  cb.onOptionChange = function(self)
    categoryId = self.currentIndex - 1
    sendHighscoreRequest(categoryId, 1, 10, 0)
  end

  window.content.filters.showOwn.onClick = function()
    showOnlyMe = true
    sendHighscoreRequest(categoryId or 0, 1, 10, 1)
  end

  window.content.next    .onClick = function() sendHighscoreRequest(categoryId, page+1,     10, 0) end
  window.content.nextLast.onClick = function() sendHighscoreRequest(categoryId, pages,      10, 0) end
  window.content.prev    .onClick = function() sendHighscoreRequest(categoryId, page-1,     10, 0) end
  window.content.prevLast.onClick = function() sendHighscoreRequest(categoryId, 1,          10, 0) end

  categoryId = 0
  page       = 1
  sendHighscoreRequest(0,1,10,0)
end

function toggle()
  if window and window:isVisible() then
    window:hide()
    button:setOn(false)
  else
    if not window then
      create()
    else
      sendHighscoreRequest(categoryId or 0, page or 1, 10, 0)
    end
    if window then
      window:show()
      button:setOn(true)
    end
  end
end

function hide()    if window then window:destroy() window=nil end end
function destroy() hide() if button then button:destroy() button=nil end end

function setColorTo(row,color)
  row.rank :setColor(color)
  row.name :setColor(color)
  row.voc  :setColor(color)
  row.level:setColor(color)
end

function load()
  button = modules.client_topmenu.addRightGameToggleButton(
    "highscoresButton", tr("Highscores"),
    "/images/topbuttons/highscore", toggle, false, 8
  )
  connect(g_game, { onGameEnd=hide })
  ProtocolGame.registerExtendedOpcode(HIGH_OP, onHighscore)
end

function unload()
  ProtocolGame.unregisterExtendedOpcode(HIGH_OP, onHighscore)
  disconnect(g_game, { onGameEnd=hide })
  destroy()
end