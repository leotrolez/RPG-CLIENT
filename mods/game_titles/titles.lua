local playerTitles = {

["Exodus"] = {title = "[Game Master]", color = "#FFA500"}}

local npcTitles = {
["Khadin"] = {title = "[Ressource Shop]", color = "#f5c367"},
["Armin"] = {title = "[Ancestral Task]", color = "#677ef5"},
["Magnus Blackwater"] = {title = "[Captain of Ships]", color = "#67caf5"},
["Shipwright Trader"] = {title = "[Ship Parts]", color = "#a68556"},
["Alaistar"] = {title = "[Potion-Ressources]", color = "#e5f280"},
["Alesar"] = {title = "[Djinn Seller]", color = "#e5f280"},
["Alexander"] = {title = "[Magician Shop]", color = "#e5f280"},
["Alice"] = {title = "[Blessing Seller]", color = "#e5f280"},
["Apotroph"] = {title = "[Mission]", color = "#67caf5"},
["Asnarus"] = {title = "[Refill Shop]", color = "#8e2b99"},
["Banker"] = {title = "[Bank]", color = "#e5f280"},
["Benjamin"] = {title = "[Postman]", color = "#e5f280"},
["Bonifacius"] = {title = "[Food Seller]", color = "#e5f280"},
["Captain Bluebear"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Breezelda"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Fearless"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Gulliver"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Kurt"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Seagull"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Seahorse"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Sinbeard"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Snake"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Thief"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Tiberius"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Waverider"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Wild"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Khaz"] = {title = "[Boat Captain]", color = "#67caf5"},
["Captain Vyrsk"] = {title = "[Expedition Isles]", color = "#67f5d6"},
["Captain Vardenfell"] = {title = "[Expedition Isles]", color = "#67f5d6"},
["Captain Hallowfall"] = {title = "[Expedition Isles]", color = "#67f5d6"},
["Captain Dorn"] = {title = "[Expedition Isles]", color = "#67f5d6"},
["Captain Frosthold"] = {title = "[Expedition Isles]", color = "#67f5d6"},
["Cledwyn"] = {title = "[Silver Token]", color = "#c4c4c4"},
["Coltrayne"] = {title = "[Equipment Shop]", color = "#946d3e"},
["Edala"] = {title = "[Blessing Seller]", color = "#e5f280"},
["Elyotrope"] = {title = "[Minner]", color = "#945e1c"},
["Elyria"] = {title = "[Herbalist]", color = "#2edb56"},
["Eremo"] = {title = "[Blessing Seller]", color = "#e5f280"},
["Eruaran"] = {title = "[Umbral Creation]", color = "#dbbe2e"},
["Esrik"] = {title = "[Equipment Shop]", color = "#946d3e"},
["Estherya"] = {title = "[Nightmare Coins]", color = "#fc3e21"},
["Feanor"] = {title = "[Tools Shop]", color = "#66d1a3"},
["Frodo"] = {title = "[Food Seller]", color = "#e5f280"},
["Gorn"] = {title = "[Tools Shop]", color = "#66d1a3"},
["Hamish"] = {title = "[Refill Shop]", color = "#8e2b99"},
["Hanna"] = {title = "[Gems Shop]", color = "#00ed63"},
["Haroun"] = {title = "[Djinn Seller]", color = "#e5f280"},
["Henricus"] = {title = "[Blessing Seller]", color = "#e5f280"},
["Humphrey"] = {title = "[Blessing Seller]", color = "#e5f280"},
["Inigo"] = {title = "[Ressource Shop]", color = "#ffd080"},
["Kawill"] = {title = "[Blessing Seller]", color = "#e5f280"},
["King Tibianus"] = {title = "[Promotion]", color = "#374d52"},
["Lailene"] = {title = "[Equipment Shop]", color = "#946d3e"},
["Librarian"] = {title = "[Passage]", color = "#ced993"},
["Nah'Bob"] = {title = "[Djinn Seller]", color = "#e5f280"},
["Norf"] = {title = "[Blessing Seller]", color = "#e5f280"},
["Peggy"] = {title = "[House Furniture]", color = "#ff7aca"},
["Plunderpurse"] = {title = "[Bank]", color = "#e5f280"},
["Pydar"] = {title = "[Blessing Seller]", color = "#e5f280"},
["Rashid"] = {title = "[Ressource Shop]", color = "#f5c367"},
["Richard"] = {title = "[Refill Shop]", color = "#8e2b99"},
["Riona"] = {title = "[Tools Shop]", color = "#66d1a3"},
["Rock In A Hard Place"] = {title = "[Equipment Shop]", color = "#946d3e"},
["Rostock"] = {title = "[Woodcutter's]", color = "#855309"},
["Royal Guard"] = {title = "[City Guard]", color = "#3d3a36"},
["Sam"] = {title = "[Equipment Shop]", color = "#946d3e"},
["Taerar"] = {title = "[Azure Seller]", color = "#3694ff"},
["Tamoril"] = {title = "[Gems Shop]", color = "#00ed63"},
["Telas"] = {title = "[Ressource Shop]", color = "#f5c367"},
["The Oracle"] = {title = "[Vocation]", color = "#57261d"},
["Tyoric"] = {title = "[Refill Shop]", color = "#8e2b99"},
["Xodet"] = {title = "[Refill Shop]", color = "#8e2b99"},
["Yaman"] = {title = "[Equipment Shop]", color = "#946d3e"},
["Yasir"] = {title = "[Ressource Shop]", color = "#f5c367"},
["Yonan"] = {title = "[Regalia of Suon]", color = "#c2a49f"},
["Shiny Bunny"] = {title = "[Easter Egg Event]", color = "#c0ff5c"},
["Rabul"] = {title = "[Dracadet Master]", color = "#c0ff5c"},
["Eppu"] = {title = "[Dracadet Master]", color = "#c0ff5c"},
["Cendevin"] = {title = "[Dracadet Master]", color = "#c0ff5c"},
["Stymie"] = {title = "[Dracadet Master]", color = "#c0ff5c"},
["Kazal"] = {title = "[Dracadet Master]", color = "#c0ff5c"},
}

local creatureTitles = {
["Vorondor The Eternal Flames"] = {title = "[Worldboss]", color = "#ff000d"},
["Aquatic Overlord Thalassa"] = {title = "[Worldboss]", color = "#ff000d"},
["Azazel The Infernal Seraph"] = {title = "[Worldboss]", color = "#ff000d"},
["Drak'thul The Void Sovereign"] = {title = "[Worldboss]", color = "#ff000d"},
["Dreadbone The Eternal"] = {title = "[Worldboss]", color = "#ff000d"},
["Dreadscale The Ancient"] = {title = "[Worldboss]", color = "#ff000d"},
["Gor'gul The Frienzied"] = {title = "[Worldboss]", color = "#ff000d"},
["Mortis The Sovereign"] = {title = "[Worldboss]", color = "#ff000d"},
["Thalador The Stormbringer"] = {title = "[Worldboss]", color = "#ff000d"},
["Tymagron The Earthshaker"] = {title = "[Worldboss]", color = "#ff000d"},


}


local titleFont = "verdana-11px-rounded"
function init()

  connect(Creature, {
    onAppear = updateTitle,
  })  
end

function terminate()

disconnect(Creature, {
    onAppear = updateTitle,
  })  
end

function updateTitle(creature)
    local name = creature:getName()
    if creature:isPlayer() then
        if playerTitles[name] then
            creature:setTitle(playerTitles[name].title, titleFont, playerTitles[name].color)
        end
	elseif creature:isNpc() then
		if npcTitles[name] then 
		creature:setTitle(npcTitles[name].title, titleFont, npcTitles[name].color)
		end
		
	elseif creature:isCreature() then 
		if creatureTitles[name] then
			creature:setTitle(creatureTitles[name].title, titleFont, creatureTitles[name].color)
		end
    end	
end