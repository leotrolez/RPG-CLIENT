--Repetitive Offsets
local typesOffSet = {
	[0] = {
		[North] = {x = 0, y = 0},
        [East] = {x = 0, y = 0},
        [South] = {x = 0, y = 0},
        [West] = {x = 0, y = 0},
	},
	[1] = {
		[North] = {x = -5, y = -5},
        [East] = {x = -13, y = 5},
        [South] = {x = 2, y = -4},
        [West] = {x = -5, y = -5},
	},
	[2] = { 
		[North] = {x = -5, y = -5},
        [East] = {x = -13, y = 5},
        [South] = {x = 2, y = -8},
        [West] = {x = -1, y = -6},
	},
    [3] = { 
		[North] = {x = 2, y = 5},
        [East] = {x = 9, y = 8},
        [South] = {x = 7, y = -1},
        [West] = {x = 2, y = -2},
	},
    [4] = {
		[North] = {x = -4, y = 8},
        [East] = {x = -4, y = 4},
        [South] = {x = 3, y = -15},
        [West] = {x = -3, y = -5},
	},
    [5] = {
		[North] = {x = 29, y = 20},
        [East] = {x = 15, y = 29},
        [South] = {x = 29, y = 16},
        [West] = {x = 23, y = 24},
	},
    [6] = {
		[North] = {x = -5, y = -5},
        [East] = {x = -8, y = 4},
        [South] = {x = 2, y = -4},
        [West] = {x = -5, y = -5},
	},
    [7] = {
		[North] = {x = -5, y = -5},
        [East] = {x = -8, y = 1},
        [South] = {x = 2, y = -4},
        [West] = {x = -5, y = -5},
	},
    [8] = {
		[North] = {x = -5, y = -5},
        [East] = {x = -5, y = 0},
        [South] = {x = 2, y = -4},
        [West] = {x = -2, y = -6},
	},
    [9] = {
		[North] = {x = -10, y = -5},
        [East] = {x = -8, y = -2},
        [South] = {x = 2, y = -4},
        [West] = {x = -5, y = -5},
	},
    [10] = {
		[North] = {x = -10, y = -5},
        [East] = {x = -8, y = -4},
        [South] = {x = 0, y = -4},
        [West] = {x = -5, y = -5},
	},
    [11] = {
		[North] = {x = -1, y = -5},
        [East] = {x = -5, y = 1},
        [South] = {x = 8, y = -6},
        [West] = {x = -4, y = 5},
	},
    [12] = {
		[North] = {x = -10, y = 0},
        [East] = {x = -12, y = 4},
        [South] = {x = 2, y = -4},
        [West] = {x = -5, y = -5},
	},
}

----- Y = - Hight / Down + // Y
----- X = - Left / Right + // X
local WingsOffsets = {
	[937] = typesOffSet[1],
	[938] = typesOffSet[4],
    [939] = typesOffSet[4],
    [940] = typesOffSet[2],
    [941] = typesOffSet[6],
    [943] = typesOffSet[6],
    [1177] = typesOffSet[7],
    [1178] = typesOffSet[8],
    [1179] = typesOffSet[9],
    [1180] = typesOffSet[10],
    [1181] = typesOffSet[9],
    [1182] = typesOffSet[10],
    [1183] = typesOffSet[10],
    [1184] = typesOffSet[10],
    [1185] = typesOffSet[11],
    [1186] = typesOffSet[12],
}


local function translateDir(dir)
    if dir == NorthEast or dir == SouthEast then
        return East
    elseif dir == NorthWest or dir == SouthWest then
        return West
    end
    return dir
end

local function getWingsInformationOffset(wing, dir)
    if WingsOffsets[wing] then
        return WingsOffsets[wing][translateDir(dir)]
    end
    return {x = 0, y = 0}
end

local function onCreatureAppear(creature)
    local Offset = getWingsInformationOffset(creature:getWings(), creature:getDirection())
    creature:setWingsOffset(Offset.x, Offset.y)
    creature:setInformationOffset(-11, -18)
end

local function onCreatureDirectionChange(creature, oldDirection, newDirection)
    local Offset = getWingsInformationOffset(creature:getWings(), newDirection)
    creature:setWingsOffset(Offset.x, Offset.y)
end

local function onCreatureOutfitChange(creature, newOutfit, oldOutfit)
    local Offset = getWingsInformationOffset(creature:getWings(), creature:getDirection())
    creature:setWingsOffset(Offset.x, Offset.y)
end

function init()
    connect(LocalPlayer, {onOutfitChange = onCreatureOutfitChange})
    connect(Creature, {
        onAppear = onCreatureAppear,
        onDirectionChange = onCreatureDirectionChange,
        onOutfitChange = onCreatureOutfitChange
    })
end

function terminate()
    disconnect(LocalPlayer, {onOutfitChange = onCreatureOutfitChange})
    disconnect(Creature, {
        onAppear = onCreatureAppear,
        onDirectionChange = onCreatureDirectionChange,
        onOutfitChange = onCreatureOutfitChange
    })
end