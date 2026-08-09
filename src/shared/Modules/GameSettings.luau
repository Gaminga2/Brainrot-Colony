--!strict
local GameSettings = {}

-- Settings Data Table
GameSettings.Data = {
	ActiveMode = "Survival",       -- Survival, PvP, Creative
	InfiniteResources = false,    -- Free building bypass
	GodMode = false,              -- Invincibility
	GhostMode = false,            -- Ghost noclip player character (ON/OFF toggle)
	SmoothGridSnapping = true,   -- Smooth lerped ghost movement
	GridLerpSpeed = 0.35,         -- Lerp factor (0.1 = super soft, 1.0 = instant)
	MewingSFX = true,             -- Brainrot voicelines & SFX
	GrassHeight = "Short",        -- Grass blade height (Off, Short, Medium, Tall)
}

-- Set a setting value
function GameSettings.set(settingName: string, value: any)
	if GameSettings.Data[settingName] ~= nil then
		GameSettings.Data[settingName] = value
		print(string.format("[GameSettings] Set '%s' = %s", settingName, tostring(value)))
	end
end

-- Get a setting value
function GameSettings.get(settingName: string): any
	return GameSettings.Data[settingName]
end

return GameSettings
