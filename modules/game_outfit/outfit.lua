ignoreNextOutfitWindow = 0
ADDON_SETS = {
	{
		1
	},
	{
		2
	},
	{
		1,
		2
	},
	{
		3
	},
	{
		1,
		3
	},
	{
		2,
		3
	},
	{
		1,
		2,
		3
	}
}
addons = nil
outfitsPreset = {}
previewDirection = 2
outfitWindow = nil
outfit = nil
outfits = nil
outfits_list = nil
mounts_list = nil
wings_list = nil
auras_list = nil
shaders_list = nil
OutfitPanel = nil
PresetPanel = nil
currentColorBox = nil
currentClotheButtonBox = nil
currentTypeButtonBox = nil
colorBoxes = {}
previewPanel = nil
previewBox = nil
typeBox = nil
mountBox = nil
auraBox = nil
wingsBox = nil
shaderBox = nil
cOutfit = nil
sId = nil
selector = nil
selectorOutfit = nil
selectorMount = nil
selectorWings = nil
selectorAuras = nil
selectorShaders = nil
selectorhealthBar = nil
selectormanaBar = nil
local outfitDir = "/outfits/"
local outfitFile = nil

function clearSearch()
	local searchInput = outfitWindow.filter:getChildById("searchInput")

	searchInput.setText(searchInput, "")
	onSearch()

	return 
end

function onSearch()
	scheduleEvent(function ()
		local label = outfitWindow.filter:getChildById("searchLabel")
		local panel = (sId == "preset" and PresetPanel) or OutfitPanel
		local searchInput = outfitWindow.filter:getChildById("searchInput")
		local text = searchInput.getText(searchInput):lower()
		local children = panel.getChildCount(panel)

		if 1 <= text.len(text) then
			for i = 1, children, 1 do
				local child = panel.getChildByIndex(panel, i)
				local childTitle = child.title

				if childTitle.getText(childTitle):lower():find(text) then
					child.show(child)
				else
					child.hide(child)
				end
			end
		else
			for i = 1, children, 1 do
				panel.getChildByIndex(panel, i):show()
			end
		end

		return 
	end, 50)

	return 
end

function init()
	connect(g_game, {
		onOpenOutfitWindow = create,
		onGameEnd = destroy
	})

	if not g_resources.directoryExists("/outfits/") then
		g_resources.makeDir("/outfits/")
	end

	return 
end

function terminate()
	disconnect(g_game, {
		onOpenOutfitWindow = create,
		onGameEnd = destroy
	})
	destroy()

	return 
end

function refreshSelector(id)
	local widget, list = nil

	if id == "type" then
		widget = selectorOutfit
		list = outfits_list
	elseif id == "mount" then
		widget = selectorMount
		list = mounts_list
	elseif id == "wings" then
		widget = selectorWings
		list = wings_list
	elseif id == "aura" then
		widget = selectorAuras
		list = auras_list
	elseif id == "shader" then
		widget = selectorShaders
		list = shaders_list
	end

	local outfit = widget.creature:getOutfit()
	local pos = 1

	for i, o in pairs(list) do
		if (id == "shader" and outfit[id] == o[2]) or outfit.type == o[1] then
			pos = i

			break
		end
	end

	if list[pos] then
		widget.label:setText(list[pos][2])

		return true
	end

	return false
end

function setupSelector(widget, id, outfit, list)
	widget.setId(widget, id)

	local name = (id == "type" and "Outfit") or id.gsub(id, "^%l", string.upper)

	outfitWindow.typeCombo:addOption(name, id)

	if id == "healthBar" or id == "manaBar" then
		table.insert(list, 1, {
			0,
			"-"
		})
	elseif id ~= "type" or #list == 0 then
		table.insert(list, 1, {
			0,
			"-"
		})
	end

	local pos = 1

	for i, o in pairs(list) do
		if (id == "shader" and outfit[id] == o[2]) or outfit[id] == o[1] then
			pos = i
		end
	end

	if list[pos] then
		widget.outfit = list[pos]

		if id == "shader" then
			widget.creature:setOutfit({
				shader = list[pos][2]
			})
		elseif id == "healthBar" then
			if pos ~= 1 then
				widget.bar:setImageSource(g_healthBars.getHealthBarPath(pos - 1))
			else
				widget.bar:setImageSource("")
			end

			widget.bar.selected = pos - 1
		elseif id == "manaBar" then
			if pos ~= 1 then
				widget.bar:setImageSource(g_healthBars.getManaBarPath(pos - 1))
			else
				widget.bar:setImageSource("")
			end

			widget.bar.selected = pos - 1
		else
			widget.creature:setOutfit({
				type = list[pos][1]
			})
		end

		widget.label:setText(list[pos][2])
	end

	return widget
end

function outfitConfig_Load()
	if g_resources.fileExists(outfitFile) then
		local status, result = pcall(function ()
			return json.decode(g_resources.readFileContents(outfitFile))
		end)

		if not status then
			return onError("Error while reading config file (" .. outfitFile .. "). To fix this problem you can delete .json. Details: " .. result)
		end

		outfitsPreset = result
	end

	return 
end

function outfitConfig_Save()
	local status, result = pcall(function ()
		return json.encode(outfitsPreset, 2)
	end)

	if not status then
		return print("Error while saving config. it won't be saved. Details: " .. result)
	end

	if 104857600 < result.len(result) then
		return print("config file is too big, above 100MB, it won't be saved")
	end

	g_resources.writeFileContents(outfitFile, result)

	return 
end

function refreshPreset(id)
	PresetPanel:destroyChildren()

	if outfitsPreset then
		for i, outfit in pairs(outfitsPreset) do
			widget = g_ui.createWidget("PresetOutfitPanel", PresetPanel)

			widget:setId(i)
			widget.title:setText(outfit.name)
			widget.mount:setOutfit({
				type = outfit.mount
			})
			widget.creature:setOutfit(outfit.outfit)

			widget.onDoubleClick = function ()
				scheduleEvent(function ()
					local tOutfit = {
						type = outfit.outfit.type,
						addons = outfit.outfit.addons,
						head = outfit.outfit.head,
						body = outfit.outfit.body,
						legs = outfit.outfit.legs,
						feet = outfit.outfit.feet
					}

					typeBox:setOutfit(tOutfit)
					mountBox:setOutfit({
						type = outfit.mount
					})
					wingsBox:setOutfit({
						type = outfit.outfit.wings
					})
					auraBox:setOutfit({
						type = outfit.outfit.aura
					})
					shaderBox:setOutfit({
						shader = outfit.outfit.shader
					})
					updateOutfit()
					refreshSelector("type")
					refreshSelector("mount")
					refreshSelector("wings")
					refreshSelector("aura")
					refreshSelector("shader")

					return 
				end, 20)

				return 
			end

			if id and i == #outfitsPreset then
				widget:focus()
				addEvent(function ()
					PresetPanel:ensureChildVisible(widget)

					return 
				end)
			end
		end
	end

	outfitWindow.outfits:setVisible(false)
	outfitWindow.presetPanel:setVisible(true)
	outfitWindow.presetOptions:setVisible(true)

	return 
end

function selectOutfit(widget)
	local list = {}
	list, selector = getOutfitListById()
	local pos = tonumber(widget.getId(widget))

	if sId ~= "healthBar" and (sId ~= "manaBar" or false) then
		local outfit = selector.creature:getOutfit()

		if sId == "shader" then
			outfit.shader = list[pos][2]
		else
			outfit.type = list[pos][1]
		end

		selector.outfit = list[pos]

		selector.creature:setOutfit(outfit)
		selector.label:setText(list[pos][2])
	end

	updateOutfit()

	return 
end

function getOutfitListById(id)
	id = id or sId
	local list = {}
	local selector = nil

	if (id == "outfit" or id == "type") and outfits_list then
		list = outfits_list
		selector = selectorOutfit
		sId = "type"
	elseif id == "mount" and mounts_list then
		list = mounts_list
		selector = selectorMount
	elseif id == "wings" and wings_list then
		list = wings_list
		selector = selectorWings
	elseif id == "aura" and auras_list then
		list = auras_list
		selector = selectorAuras
	elseif id == "shader" and shaders_list then
		list = shaders_list
		selector = selectorShaders
	end

	return list, selector
end

function onTypeChange(widgetType, option)
	local list = {}
	local current = 1

	if type(widgetType) == "userdata" then
		sId = widgetType.getCurrentOption(widgetType).data
	else
		sId = widgetType
	end

	if sId == "preset" then
		outfitConfig_Load()
		refreshPreset()

		return 
	else
		OutfitPanel:destroyChildren()

		local player = g_game.getLocalPlayer()
		local specOutfit = player.getOutfit(player)
		list = getOutfitListById()

		if sId == "outfit" then
			sId = "type"
		end

		for i, o in pairs(list) do
			if (sId == "shader" and cOutfit[sId] == o[2]) or cOutfit[sId] == o[1] then
				current = i
			end
		end

		if 0 < #list then
			for i = 1, #list, 1 do
				local widget = g_ui.createWidget("OutfitCreature", OutfitPanel)

				widget.setId(widget, i)

				specOutfit.mount = 0
				specOutfit.shader = ""
				specOutfit.aura = 0
				specOutfit.wings = 0

				widget.title:setText(list[i][2])

				if sId == "shader" then
					specOutfit.shader = list[i][2]

					if specOutfit.shader == "-" then
						specOutfit.shader = ""
					end
				else
					specOutfit.type = list[i][1]
				end

				specOutfit.addons = list[i][3]

				widget.outfit:setOutfit(specOutfit)

				if current == i then
					widget.focus(widget)
					addEvent(function ()
						OutfitPanel:ensureChildVisible(widget)

						return 
					end)
				end
			end
		end
	end

	outfitWindow.outfits:setVisible(true)
	outfitWindow.presetPanel:setVisible(false)
	outfitWindow.presetOptions:setVisible(false)

	return 
end

function singlelineEditorWindow(text, options, callback)
	options = options or {}
	options.multiline = false
	local window = modules.client_textedit.edit(text, options, callback)

	return window
end

function outfitConfirmationWindow(title, question, callback)
	local window = nil

	local function onConfirm()
		window:destroy()
		callback()

		return 
	end

	local function closeWindow()
		window:destroy()

		return 
	end

	window = displayGeneralBox(title, question, {
		{
			text = tr("Yes"),
			callback = onConfirm
		},
		{
			text = tr("No"),
			callback = closeWindow
		},
		anchor = AnchorHorizontalCenter
	}, onConfirm, closeWindow)

	return window
end

function create(currentOutfit, outfitList, mountList, wingList, auraList, shaderList, hpBarList, manaBarList)
	if ignoreNextOutfitWindow and g_clock.millis() < ignoreNextOutfitWindow + 1000 then
		return 
	end

	if outfitWindow and not outfitWindow:isHidden() then
		return 
	end

	destroy()

	outfitFile = outfitDir .. g_game.getLocalPlayer():getName() .. "_outfit.json"
	outfits_list = outfitList
	mounts_list = mountList
	wings_list = wingList
	auras_list = auraList
	shaders_list = shaderList
	cOutfit = currentOutfit
	outfitWindow = g_ui.displayUI("outfitwindow")
	selectorOutfit = setupSelector(g_ui.createWidget("OutfitSelectorPanel", outfitWindow.extensions), "type", currentOutfit, outfitList)
	typeBox = outfitWindow.extensions.type.creature
	OutfitPanel = outfitWindow.outfits.list
	PresetPanel = outfitWindow.presetPanel.list
	previewPanel = outfitWindow.preview
	previewBox = previewPanel.creature
	local outfit = typeBox:getOutfit()
	outfit.head = currentOutfit.head
	outfit.body = currentOutfit.body
	outfit.legs = currentOutfit.legs
	outfit.feet = currentOutfit.feet

	typeBox:setOutfit(outfit)

	if g_game.getFeature(GamePlayerMounts) then
		selectorMount = setupSelector(g_ui.createWidget("OutfitSelectorPanel", outfitWindow.extensions), "mount", currentOutfit, mountList)
	end

	if g_game.getFeature(GameWingsAndAura) then
		selectorWings = setupSelector(g_ui.createWidget("OutfitSelectorPanel", outfitWindow.extensions), "wings", currentOutfit, wingList)
		selectorAuras = setupSelector(g_ui.createWidget("OutfitSelectorPanel", outfitWindow.extensions), "aura", currentOutfit, auraList)
	end

	if g_game.getFeature(GameOutfitShaders) then
		selectorShaders = setupSelector(g_ui.createWidget("OutfitSelectorPanel", outfitWindow.extensions), "shader", currentOutfit, shaderList)
	end

	outfitWindow.typeCombo:addOption("Preset", "preset")

	mountOutfit = outfitWindow.extensions.mount.creature
	mountBox = outfitWindow.extensions.mount.creature
	auraBox = outfitWindow.extensions.aura.creature
	wingsBox = outfitWindow.extensions.wings.creature
	shaderBox = outfitWindow.extensions.shader.creature
	addons = {
		{
			value = 1,
			widget = outfitWindow.addon1
		},
		{
			value = 2,
			widget = outfitWindow.addon2
		},
		{
			value = 4,
			widget = outfitWindow.addon3
		}
	}
	outfitWindow.typeCombo.onOptionChange = onTypeChange

	for j = 0, 6, 1 do
		for i = 0, 18, 1 do
			local colorBox = g_ui.createWidget("ColorBox", outfitWindow.colorBoxPanel)
			local outfitColor = getOutfitColor(j*19 + i)

			colorBox.setImageColor(colorBox, outfitColor)
			colorBox.setId(colorBox, "colorBox" .. j*19 + i)

			colorBox.colorId = j*19 + i

			if j*19 + i == currentOutfit.head then
				currentColorBox = colorBox

				colorBox.setChecked(colorBox, true)
			end

			colorBox.onCheckChange = onColorCheckChange
			colorBoxes[#colorBoxes + 1] = colorBox
		end
	end

	if previewPanel.showmount:isChecked() then
		outfit.mount = currentOutfit.mount
	else
		outfit.mount = 0
	end

	previewBox:setOutfit(currentOutfit)

	for _, addon in pairs(addons) do
		addon.widget.onCheckChange = function (self)
			onAddonCheckChange(self, addon.value)

			return 
		end
	end

	if currentOutfit.addons and 0 < currentOutfit.addons then
		for _, i in pairs(ADDON_SETS[currentOutfit.addons]) do
			addons[i].widget:setChecked(true)
		end
	end

	currentClotheButtonBox = outfitWindow.head
	outfitWindow.head.onCheckChange = onClotheCheckChange
	outfitWindow.primary.onCheckChange = onClotheCheckChange
	outfitWindow.secondary.onCheckChange = onClotheCheckChange
	outfitWindow.detail.onCheckChange = onClotheCheckChange

	previewBox:setOutfit(outfit)
	previewBox:setDirection(previewDirection)

	previewPanel.turnLeft.onClick = function ()
		previewDirection = (previewDirection ~= 3 or 0) and previewDirection + 1

		previewBox:setDirection(previewDirection)

		return 
	end
	previewPanel.turnRight.onClick = function ()
		previewDirection = (previewDirection == 0 and 3) or previewDirection - 1

		previewBox:setDirection(previewDirection)

		return 
	end
	local optionOutfit = modules.client_options.getOption("showoutfit") or true
	local optionMount = modules.client_options.getOption("showmount") or false
	local optionWings = modules.client_options.getOption("showwings") or false
	local optionAura = modules.client_options.getOption("showaura") or false
	local optionShader = modules.client_options.getOption("showshader") or false
	local optionAnimated = modules.client_options.getOption("animated") or false

	previewPanel.showoutfit:setChecked(optionOutfit)
	previewPanel.showmount:setChecked(optionMount)
	previewPanel.showwings:setChecked(optionWings)
	previewPanel.showaura:setChecked(optionAura)
	previewPanel.showshader:setChecked(optionShader)
	previewPanel.animated:setChecked(optionAnimated)

	previewPanel.showoutfit.onCheckChange = onOutfitCheckChange
	previewPanel.showmount.onCheckChange = onOutfitCheckChange
	previewPanel.showwings.onCheckChange = onOutfitCheckChange
	previewPanel.showaura.onCheckChange = onOutfitCheckChange
	previewPanel.showshader.onCheckChange = onOutfitCheckChange
	previewPanel.animated.onCheckChange = onOutfitCheckChange

	onTypeChange("type")
	updateOutfit()

	return 
end

function presetAction(action)
	local text, index = nil
	local data = typeBox:getOutfit()
	local mount = mountBox:getOutfit()
	local aura = auraBox:getOutfit()
	local wings = wingsBox:getOutfit()
	local shader = shaderBox:getOutfit()
	mount = (mount and mount.type) or 0
	aura = (aura and aura.type) or 0
	wings = (wings and wings.type) or 0
	shader = (shader and shader.shader) or ""
	local selected = PresetPanel:getFocusedChild()

	if selected then
		index = PresetPanel:getChildIndex(selected)
		text = selected.title:getText()
	end

	if action == "new" then
		local tmpTitle = selectorOutfit.label:getText()

		singlelineEditorWindow(tmpTitle, {
			title = "Enter outfit name."
		}, function (name)
			if 1 < name.len(name) then
				table.insert(outfitsPreset, {
					name = name,
					outfit = {
						type = data.type,
						head = data.head,
						body = data.body,
						legs = data.legs,
						feet = data.feet,
						addons = data.addons,
						aura = aura,
						wings = wings,
						shader = shader
					},
					mount = mount
				})
				outfitConfig_Save()
				refreshPreset(true)
			end

			return 
		end)
	elseif action == "rename" then
		if 0 < index then
			singlelineEditorWindow(text, {
				title = "Enter new name."
			}, function (name)
				if 3 < name.len(name) then
					outfitsPreset[index].name = name

					selected.title:setText(name)
					outfitConfig_Save()
					selected:setBorderColor("green")
				end

				return 
			end)
		end
	elseif action == "save" then
		if 0 < index then
			outfitConfirmationWindow("Confirm Save?", tr("Are you sure you want to overwrite " .. text .. "?"), function ()
				outfitsPreset[index] = {
					name = text,
					outfit = {
						type = data.type,
						head = data.head,
						body = data.body,
						legs = data.legs,
						feet = data.feet,
						addons = data.addons,
						aura = aura,
						wings = wings,
						shader = shader
					},
					mount = mount
				}

				outfitConfig_Save()
				refreshPreset(true)
				selected:setBorderColor("green")

				return 
			end)
		end
	elseif action == "delete" and 0 < index then
		outfitConfirmationWindow("Confirm deletion?", tr("Are you sure you want to delete " .. text .. "?"), function ()
			table.remove(outfitsPreset, index)
			outfitConfig_Save()
			refreshPreset(true)

			return 
		end)
	end

	return 
end

function destroy()
	if outfitWindow then
		outfitWindow:destroy()

		outfitWindow = nil
		currentColorBox = nil
		currentClotheButtonBox = nil
		colorBoxes = {}
		addons = {}
	end

	return 
end

function randomizeAll()
	local outfitTemplate = {
		outfitWindow.head,
		outfitWindow.primary,
		outfitWindow.secondary,
		outfitWindow.detail
	}

	for i = 1, #outfitTemplate, 1 do
		outfitTemplate[i]:setChecked(true)
		colorBoxes[math.random(1, #colorBoxes)]:setChecked(true)
		outfitTemplate[i]:setChecked(false)
	end

	outfitTemplate[1]:setChecked(true)

	local out = typeBox:getOutfit()
	out.type = outfits_list[math.random(#outfits_list)][1]
	local out1 = mounts_list[math.random(1, #mounts_list)][1]
	local out2 = wings_list[math.random(1, #wings_list)][1]
	local out3 = auras_list[math.random(1, #auras_list)][1]
	local out4 = shaders_list[math.random(1, #shaders_list)][2]

	if out4 == "-" then
		out4 = ""
	end

	typeBox:setOutfit(out)
	mountBox:setOutfit({
		type = out1
	})
	wingsBox:setOutfit({
		type = out2
	})
	auraBox:setOutfit({
		type = out3
	})

	out.shader = out4

	shaderBox:setOutfit(out)
	updateOutfit()
	refreshSelector("type")
	refreshSelector("mount")
	refreshSelector("wings")
	refreshSelector("aura")
	refreshSelector("shader")

	return 
end

function randomizeOutfit()
	local out = typeBox:getOutfit()
	out.type = outfits_list[math.random(#outfits_list)][1]

	if out4 == "-" then
		out4 = ""
	end

	typeBox:setOutfit(out)
	mountBox:setOutfit({
		type = out1
	})
	wingsBox:setOutfit({
		type = out2
	})
	auraBox:setOutfit({
		type = out3
	})

	out.shader = out4

	shaderBox:setOutfit(out)
	updateOutfit()
	refreshSelector("type")
	refreshSelector("mount")
	refreshSelector("wings")
	refreshSelector("aura")
	refreshSelector("shader")

	return 
end

function randomizeColor()
	local outfitTemplate = {
		outfitWindow.head,
		outfitWindow.primary,
		outfitWindow.secondary,
		outfitWindow.detail
	}

	for i = 1, #outfitTemplate, 1 do
		outfitTemplate[i]:setChecked(true)
		colorBoxes[math.random(1, #colorBoxes)]:setChecked(true)
		outfitTemplate[i]:setChecked(false)
	end

	outfitTemplate[1]:setChecked(true)
	updateOutfit()

	return 
end

function accept()
	local outfit = typeBox:getOutfit()

	for i, child in pairs(outfitWindow.extensions:getChildren()) do
		if child.getId(child) == "healthBar" or child.getId(child) == "manaBar" then
			outfit[child.getId(child)] = child.bar.selected
		elseif child.creature:getCreature() then
			if child.getId(child) == "shader" then
				outfit[child.getId(child)] = child.creature:getOutfit().shader
			else
				outfit[child.getId(child)] = child.creature:getOutfit().type
			end
		end
	end

	g_game.changeOutfit(outfit)
	destroy()

	return 
end

function onAddonCheckChange(addon, value)
	local outfit = typeBox:getOutfit()

	if addon.isChecked(addon) then
		outfit.addons = outfit.addons + value
	else
		outfit.addons = outfit.addons - value
	end

	typeBox:setOutfit(outfit)
	previewBox:setOutfit(outfit)

	return 
end

function onOutfitCheckChange(addon, value)
	modules.client_options.setOption(addon.getId(addon), value)
	updateOutfit()

	return 
end

function onColorCheckChange(colorBox)
	local outfit = outfitWindow.extensions.type.creature:getOutfit()

	if colorBox == currentColorBox then
		colorBox.onCheckChange = nil

		colorBox.setChecked(colorBox, true)

		colorBox.onCheckChange = onColorCheckChange
	else
		if currentColorBox then
			currentColorBox.onCheckChange = nil

			currentColorBox:setChecked(false)

			currentColorBox.onCheckChange = onColorCheckChange
		end

		currentColorBox = colorBox

		if currentClotheButtonBox:getId() == "head" then
			outfit.head = currentColorBox.colorId
		elseif currentClotheButtonBox:getId() == "primary" then
			outfit.body = currentColorBox.colorId
		elseif currentClotheButtonBox:getId() == "secondary" then
			outfit.legs = currentColorBox.colorId
		elseif currentClotheButtonBox:getId() == "detail" then
			outfit.feet = currentColorBox.colorId
		end

		previewBox:setOutfit(outfit)
		typeBox:setOutfit(outfit)
	end

	return 
end

function onClotheCheckChange(clotheButtonBox)
	local outfit = typeBox:getOutfit()

	if clotheButtonBox == currentClotheButtonBox then
		clotheButtonBox.onCheckChange = nil

		clotheButtonBox.setChecked(clotheButtonBox, true)

		clotheButtonBox.onCheckChange = onClotheCheckChange
	else
		currentClotheButtonBox.onCheckChange = nil

		currentClotheButtonBox:setChecked(false)

		currentClotheButtonBox.onCheckChange = onClotheCheckChange
		currentClotheButtonBox = clotheButtonBox
		local colorId = 0

		if currentClotheButtonBox:getId() == "head" then
			colorId = outfit.head
		elseif currentClotheButtonBox:getId() == "primary" then
			colorId = outfit.body
		elseif currentClotheButtonBox:getId() == "secondary" then
			colorId = outfit.legs
		elseif currentClotheButtonBox:getId() == "detail" then
			colorId = outfit.feet
		end

		outfitWindow:recursiveGetChildById("colorBox" .. colorId):setChecked(true)
	end

	return 
end

function updateOutfit()
	local currentSelection = outfitWindow.extensions.type.outfit

	if not currentSelection then
		return 
	end

	local outfit = outfitWindow.extensions.type.creature:getOutfit()
	local availableAddons = currentSelection[3]
	local prevAddons = {}

	for k, addon in pairs(addons) do
		prevAddons[k] = addon.widget:isChecked()

		addon.widget:setChecked(false)
		addon.widget:setEnabled(false)
	end

	outfit.addons = 0

	if selectorMount then
		if previewPanel.showmount:isChecked() then
			outfit.mount = mountBox:getOutfit().type
		else
			outfit.mount = 0
		end
	end

	if selectorWings then
		if previewPanel.showwings:isChecked() then
			outfit.wings = wingsBox:getOutfit().type
		else
			outfit.wings = 0
		end
	end

	if selectorAuras then
		if previewPanel.showaura:isChecked() then
			outfit.aura = auraBox:getOutfit().type
		else
			outfit.aura = 0
		end
	end

	if selectorShaders then
		if previewPanel.showshader:isChecked() then
			outfit.shader = shaderBox:getOutfit().shader
		else
			outfit.shader = ""
		end
	end

	previewBox:setOutfit(outfit)

	if not previewPanel.showoutfit:isChecked() then
		outfit.type = 800
		outfit.shader = ""
	end

	if 0 < availableAddons then
		for _, i in pairs(ADDON_SETS[availableAddons]) do
			addons[i].widget:setEnabled(true)
			addons[i].widget:setChecked(true)
		end
	end

	outfit.addons = availableAddons

	previewBox:setOutfit(outfit)

	if previewPanel.animated:isChecked() then
		previewBox:setAnimate(true)
	else
		previewBox:setAnimate(false)
	end

	g_game.changeOutfit(outfit)

	return 
end

return 