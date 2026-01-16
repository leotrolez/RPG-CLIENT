SOUNDS_CONFIG = {
	soundChannel = SoundChannels.Music,
	checkInterval = 1100,
	folder = 'music/',
	noSound = 'No sound file for this area.',
}

SOUNDS = {
	-- Test Music
	{fromPos = {x=1923, y=361, z=7}, toPos = {x=1987, y=390, z=7}, priority = 0, sound = "Kindernia Entrance.ogg"},
	{fromPos = {x=1923, y=361, z=6}, toPos = {x=1987, y=390, z=6}, priority = 0, sound = "Kindernia Entrance.ogg"},
	{fromPos = {x=1923, y=361, z=5}, toPos = {x=1987, y=390, z=5}, priority = 0, sound = "Kindernia Entrance.ogg"},
	{fromPos = {x=1923, y=361, z=4}, toPos = {x=1987, y=390, z=4}, priority = 0, sound = "Kindernia Entrance.ogg"},

	
		
		
} 

-- Sound
local gameSoundChannel
local showPosEvent
local playingSound

-- Design
soundWindow = nil
soundButton = nil

function toggle()
  if soundButton:isOn() then
    soundWindow:close()
    soundButton:setOn(false)
  else
    soundWindow:open()
    soundButton:setOn(true)
  end
end

function onMiniWindowClose()
  soundButton:setOn(false)
end

function init()
	for i = 1, #SOUNDS do
		SOUNDS[i].sound = SOUNDS_CONFIG.folder .. SOUNDS[i].sound
	end
	
	connect(g_game, { onGameStart = onGameStart,
                    onGameEnd = onGameEnd })
	
	gameSoundChannel = g_sounds.getChannel(SOUNDS_CONFIG.soundChannel)

	soundButton = modules.client_topmenu.addRightGameToggleButton('soundButton', tr('Area Sound') .. '', '/images/topbuttons/soundButton', toggle)
	soundButton:setOn(true)
	
	soundWindow = g_ui.loadUI('gamesounds', modules.game_interface.getRightPanel())
	soundWindow:disableResize()
	soundWindow:setup()
	
	if(g_game.isOnline()) then
		onGameStart()
	end
end

function terminate()
	disconnect(g_game, { onGameStart = onGameStart,
                       onGameEnd = onGameEnd })
	onGameEnd()
	soundWindow:destroy()
	soundButton:destroy()
end

function onGameStart()
	stopSound()
	toggleSoundEvent = addEvent(toggleSound, SOUNDS_CONFIG.checkInterval)
end

function onGameEnd()
	stopSound()
	removeEvent(toggleSoundEvent)
end

function isInPos(pos, fromPos, toPos)
	return
		pos.x>=fromPos.x and
		pos.y>=fromPos.y and
		pos.z>=fromPos.z and
		pos.x<=toPos.x and
		pos.y<=toPos.y and
		pos.z<=toPos.z
end

function toggleSound()
	local player = g_game.getLocalPlayer()
	if not player then return end
	
	local pos = player:getPosition()
	local toPlay = nil

	for i = 1, #SOUNDS do
		if(isInPos(pos, SOUNDS[i].fromPos, SOUNDS[i].toPos)) then
			if(toPlay) then
				toPlay.priority = toPlay.priority or 0
				if((toPlay.sound~=SOUNDS[i].sound) and (SOUNDS[i].priority>toPlay.priority)) then
					toPlay = SOUNDS[i]
				end
			else
				toPlay = SOUNDS[i]
			end
		end
	end

	playingSound = playingSound or {sound='', priority=0}
	
	if(toPlay~=nil and playingSound.sound~=toPlay.sound) then
		g_logger.info("Game Sounds: New sound area detected:")
		g_logger.info("  Position: {x=" .. pos.x .. ", y=" .. pos.y .. ", z=" .. pos.z .. "}")
		g_logger.info("  Music: " .. toPlay.sound)
		stopSound()
		playSound(toPlay.sound)
		playingSound = toPlay
	elseif(toPlay==nil) and (playingSound.sound~='') then
		g_logger.info("Game Sounds: New sound area detected:")
		g_logger.info("  Left music area.")
		stopSound()
	end

	toggleSoundEvent = scheduleEvent(toggleSound, SOUNDS_CONFIG.checkInterval)
end

function playSound(sound)
	gameSoundChannel:enqueue(sound, 0)
	gameSoundChannel:setGain(1/2)
	setLabel(clearName(sound))
end

function clearName(soundName)
	local explode = string.explode(soundName, "/")
	soundName = explode[#explode]
	explode = string.explode(soundName, ".ogg")
	soundName = ''
	for i = 1, #explode-1 do
		soundName = soundName .. explode[i]
	end
	return soundName
end

function stopSound()
	setLabel(SOUNDS_CONFIG.noSound)
	gameSoundChannel:stop()
	playingSound = nil
end

function setLabel(str)
	soundWindow:recursiveGetChildById('currentSound'):getChildById('value'):setText(str)
end