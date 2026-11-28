local debris = game:GetService("Debris")
local SoundManager = {}

-- Встроенные звуки Roblox (работают без загрузки собственных аудиофайлов)
local SOUNDS = {
	HitCrystal   = {Id = "rbxassetid://9119713951", Volume = 0.6, Pitch = 1.1},  -- Удар по кристаллу
	BreakCrystal = {Id = "rbxassetid://4612375233", Volume = 0.8, Pitch = 1.0},  -- Звонкий сбор кристалла
	BuyUpgrade   = {Id = "rbxassetid://4612383790", Volume = 0.7, Pitch = 1.0},  -- Покупка постройки / апгрейда
	Rebirth      = {Id = "rbxassetid://131961136",  Volume = 0.9, Pitch = 1.0}   -- Эпичный звук перерождения
}

function SoundManager.Play(soundName, parentPart)
	local info = SOUNDS[soundName]
	if not info then return end

	local sound = Instance.new("Sound")
	sound.SoundId = info.Id
	sound.Volume = info.Volume
	sound.PlaybackSpeed = info.Pitch
	-- Если указана деталь (например, кристалл или плита) — звук будет объёмным 3D, иначе слышен всем
	sound.Parent = parentPart or workspace
	sound:Play()

	debris:AddItem(sound, 3)
end

return SoundManager
