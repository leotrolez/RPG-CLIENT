local OPCODE = 61
local window, creatureBarHP, creatureHP, creatureName = nil
local focusedBoss = 0
local focusedMob = 0

function init()
	connect(g_game, {
		onGameStart = create,
		onGameEnd = destroy,
		onAttackingCreatureChange = onAttackingCreatureChange,
		onAppear = onCreatureAppear,
		onDisappear = onCreatureDisappear
	})
	connect(Creature, {
		onHealthPercentChange = onHealthPercentChange,
		onSpecialPercentChange = onSpecialPercentChange,
		onAppear = onCreatureAppear,
		onDisappear = onCreatureDisappear
	})

	if g_game.isOnline() then
		create()
	end
end

function terminate()
	disconnect(g_game, {
		onGameStart = create,
		onGameEnd = destroy,
		onAttackingCreatureChange = onAttackingCreatureChange,
		onAppear = onCreatureAppear,
		onDisappear = onCreatureDisappear
	})
	disconnect(Creature, {
		onHealthPercentChange = onHealthPercentChange,
		onSpecialPercentChange = onSpecialPercentChange,
		onAppear = onCreatureAppear,
		onDisappear = onCreatureDisappear
	})
	destroy()
end

function create()
	if window then
		return
	end

	window = g_ui.loadUI("bossbar", modules.game_interface.getMapPanel())

	window:hide()

	creatureBarHP = window:recursiveGetChildById("creatureBarHP")
	creatureName = window:recursiveGetChildById("creatureName")
	creatureHP = window:recursiveGetChildById("creatureHP")
	creatureSpecial = window:recursiveGetChildById("special")
end

function destroy()
	if window then
		window:destroy()

		window = nil
		creatureBarHP = nil
		creatureHP = nil
		creatureOutfit = nil
		creatureName = nil
		creatureSpecial = nil
		focusedBoss = 0
		focusedMob = 0
	end
end

function onExtendedOpcode(protocol, code, buffer)
	if not g_game.isOnline() then
		return
	end

	local json_status, json_data = pcall(function ()
		return json.decode(buffer)
	end)

	if not json_status then
		g_logger.error("[Boss Bar] JSON error: " .. data)

		return false
	end

	if json_data.action == "show" then
		show(json_data.data)
	elseif json_data.action == "hide" then
		hide()
	end
end

function show(data)
	focusedBoss = data.cid
	creatureName:setText(data.name)
	creatureHP:setText(data.health .. "%")
	creatureSpecial:setPercent(data.health)
	window:show()
end

function hide()
	focusedBoss = 0
	focusedMob = 0

	window:hide()
end

bossBarEnabled = true

function setEnabled(value)
	bossBarEnabled = value
end


local bossNames = {
    "Azure [1]",
	"Azure [2]",
	"Azure [3]",
	"Azure [4]",
	"Azure [5]",
	"Azure [6]",
	"Azure [7]",
	"Azure [8]",
	"Azure [9]",
	"Azure [10]",
    "Master of the Elements [1]",
	"Master of the Elements [2]",
	"Master of the Elements [3]",
	"Master of the Elements [4]",
	"Master of the Elements [5]",
	"Master of the Elements [6]",
	"Master of the Elements [7]",
	"Master of the Elements [8]",
	"Master of the Elements [9]",
	"Master of the Elements [10]",
	"Deep Necromancer [1]",
	"Deep Necromancer [2]",
	"Deep Necromancer [3]",
	"Deep Necromancer [4]",
	"Deep Necromancer [5]",
	"Deep Necromancer [6]",
	"Deep Necromancer [7]",
	"Deep Necromancer [8]",
	"Deep Necromancer [9]",
	"Deep Necromancer [10]",
	"Terror Spider [1]",
	"Terror Spider [2]",
	"Terror Spider [3]",
	"Terror Spider [4]",
	"Terror Spider [5]",
	"Terror Spider [6]",
	"Terror Spider [7]",
	"Terror Spider [8]",
	"Terror Spider [9]",
	"Terror Spider [10]",
	"Bakragore",
	"Chagorz",
	"Ichgahal",
	"Murcion",
	"Vemiath",
	"Drume",
	"Brokul",
	"Scarlett Etzel",
	"Prince Skeletal [1]",
	"Prince Skeletal [2]",
	"Prince Skeletal [3]",
	"Prince Skeletal [4]",
	"Prince Skeletal [5]",
	"Prince Skeletal [6]",
	"Prince Skeletal [7]",
	"Prince Skeletal [8]",
	"Prince Skeletal [9]",
	"Prince Skeletal [10]",
	"The Dread Maider",
	"The Fear Feaster",
	"The Paleworm",
	"The Unwelcome",
	"King Zelos",
	"Urmahlullu the immaculate",
	"Urmahlullu the tamed",
	"Urmahlullu the weakened",
	"wildness of urmahlullu",
	"wisdom of urmahlullu",
	"gulosh",
	"gorzindel",
	"lokathmor",
	"mazzinor",
	"the scourge of oblivion",
	"goshnar's cruelty",
	"goshnar's greed",
	"goshnar's hatred",
	"goshnar's malice",
	"goshnar's megalomania",
	"goshnar's spite",
	"abyssador",
	"deathstrike",
	"deep terror",
	"gnomevil",
	"plagirath",
	"professor maxxen",
	"ushuriel",
	"jaul",
	"Gaz'Haragoth",
	"Mawhawk",
	"Omrafir",
	"Morgaroth",
	"Crustacea Gigantica",
	"Orshabaal",
	"Ferumbras",
	"Midnight Panther",
	"Zulazza the Corruptor",
	"Chizzoron the Distorter",
	"Ghazbaran",
	"Zushuka",
	"Aquatic Overlord Thalassa",
	"Azazel The Infernal Seraph",
	"Drak'thul The Void Sovereign",
	"Dreadbone The Eternal",
	"Dreadscale The Ancient",
	"Gor'gul The Frienzied",
	"Mortis The Sovereign",
	"Thalador The Stormbringer",
	"Tymagron The Earthshaker",
	"Vorondor The Eternal Flames",
	"Arodis Saron",
	"Astro King", 
	"Blessed Archangel",
	"Mercurial Mage",
	"Ashseer Dravok",
	"Emberlord Zanarth",
	"Hollowborn Zepharix",
	"Icebound Thryssan",
	"Tidebreaker Voryn",
	"Voidweaver Krythax"
}

function checkBossName(name)
    for _, bossName in ipairs(bossNames) do
        if string.lower(name) == string.lower(bossName) then
            return true
        end
    end
    return false
end

function onAttackingCreatureChange(creature, oldCreature)
    if bossBarEnabled then
        if focusedBoss ~= 0 then
            return
        end
        if creature and checkBossName(creature:getName()) then
            creatureHP:setText(creature:getHealthPercent() .. "%")
            creatureSpecial:setPercent(creature:getHealthPercent())
            focusedMob = creature:getId()
            window:show()
        else
            hide()
        end
    else
        hide()
    end
end


function onCreatureAppear(creature)
    if bossBarEnabled then
        if focusedBoss ~= 0 then
            return
        end
        if creature and checkBossName(creature:getName()) then
            creatureName:setText(creature:getName())
            creatureHP:setText(creature:getHealthPercent() .. "%")
            creatureSpecial:setPercent(creature:getHealthPercent())
            focusedMob = creature:getId()
            window:show()
        end
    end
end

function onCreatureDisappear(creature)
    if bossBarEnabled and (creature:getId() == focusedMob or creature:getId() == focusedBoss) then
        hide()
    end
end

function onHealthPercentChange(creature, health)
	if bossBarEnabled then
		if focusedBoss == creature:getId() or focusedMob == creature:getId() then
			creatureHP:setText(health .. "%")
			creatureSpecial:setPercent(health)
		end
	else
		hide()
	end
end

function onSpecialPercentChange(creature, special)
	if special > 0 then
		if not creatureSpecial:isVisible() then
			creatureSpecial:setVisible(true)
		end
		creatureSpecial:setPercent(special)
	else
		creatureSpecial:setVisible(false)
	end
end

