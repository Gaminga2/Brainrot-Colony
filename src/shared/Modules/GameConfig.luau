--!strict
local GameConfig = {}

-- Voxel Snap Grid Configuration
GameConfig.GRID_SIZE = 4 -- 4x4x4 studs per voxel block
GameConfig.MAX_BUILD_HEIGHT = 120 -- max height in studs

-- Resources
GameConfig.Resources = {
	OhioWood = { Name = "Ohio Wood", Color = Color3.fromRGB(139, 90, 43) },
	GyattGranite = { Name = "Gyatt Granite", Color = Color3.fromRGB(128, 128, 128) },
	RizziteAlloy = { Name = "Rizzite Alloy", Color = Color3.fromRGB(0, 200, 255) },
}

-- Block Types & Health
GameConfig.Blocks = {
	WoodWall = {
		Name = "Wood Wall",
		Material = Enum.Material.Wood,
		Color = Color3.fromRGB(150, 95, 45),
		MaxHP = 100,
		Cost = { OhioWood = 5 },
	},
	StoneWall = {
		Name = "Stone Wall",
		Material = Enum.Material.Cobblestone,
		Color = Color3.fromRGB(110, 110, 115),
		MaxHP = 300,
		Cost = { GyattGranite = 8 },
	},
	RizziteReinforcedWall = {
		Name = "Rizzite Shield Wall",
		Material = Enum.Material.Neon,
		Color = Color3.fromRGB(0, 220, 255),
		MaxHP = 750,
		Cost = { GyattGranite = 10, RizziteAlloy = 5 },
	},
	SpikeTrap = {
		Name = "Spike Trap",
		Material = Enum.Material.Metal,
		Color = Color3.fromRGB(60, 60, 60),
		MaxHP = 150,
		Cost = { OhioWood = 3, GyattGranite = 4 },
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
