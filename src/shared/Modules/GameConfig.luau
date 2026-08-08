--!strict
local GameConfig = {}

-- Voxel Snap Grid Configuration
-- Standard Roblox avatar is ~5.0 - 5.5 studs tall.
-- 1 block = 2 x 2 x 2 studs (3 blocks stacked = 6 studs = ~1 NPC height).
GameConfig.GRID_SIZE = 2 -- 2x2x2 studs per voxel block
GameConfig.MAX_BUILD_HEIGHT = 150 -- max height in studs

-- Resources
GameConfig.Resources = {
	OhioWood = { Name = "Ohio Wood", Color = Color3.fromRGB(139, 90, 43) },
	GyattGranite = { Name = "Gyatt Granite", Color = Color3.fromRGB(128, 128, 128) },
	RizziteAlloy = { Name = "Rizzite Alloy", Color = Color3.fromRGB(0, 200, 255) },
}

-- Block Types & Health (Balanced for 2-stud grid units)
GameConfig.Blocks = {
	WoodWall = {
		Name = "Wood Block",
		Material = Enum.Material.Wood,
		Color = Color3.fromRGB(150, 95, 45),
		MaxHP = 50,
		Cost = { OhioWood = 2 },
	},
	StoneWall = {
		Name = "Stone Block",
		Material = Enum.Material.Cobblestone,
		Color = Color3.fromRGB(110, 110, 115),
		MaxHP = 150,
		Cost = { GyattGranite = 3 },
	},
	RizziteReinforcedWall = {
		Name = "Rizzite Shield Block",
		Material = Enum.Material.Neon,
		Color = Color3.fromRGB(0, 220, 255),
		MaxHP = 350,
		Cost = { GyattGranite = 4, RizziteAlloy = 2 },
	},
	SpikeTrap = {
		Name = "Spike Trap",
		Material = Enum.Material.Metal,
		Color = Color3.fromRGB(60, 60, 60),
		MaxHP = 80,
		Cost = { OhioWood = 1, GyattGranite = 2 },
		Damage = 25,
	},
}

-- Game Modes
GameConfig.GameModes = {
	SURVIVAL = "Survival",
	PVP = "PvP",
}

-- Survival Settings
GameConfig.Survival = {
	DayDurationSeconds = 60,
	NightDurationSeconds = 90,
	InitialCoreHP = 1000,
}

-- PvP Settings
GameConfig.PvP = {
	BuildPhaseSeconds = 300,
	WarPhaseSeconds = 600,
	InitialCoreHP = 2000,
}

return GameConfig
