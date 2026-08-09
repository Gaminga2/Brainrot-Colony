--!strict
local GameConfig = {}

-- Project Metadata
GameConfig.PROJECT_NAME = "Brainrot Castle (Brainrot Colony)"
GameConfig.VERSION = "v0.0.0.21"

-- Voxel Snap Grid Configuration (2x2x2 studs = ~1/3 Roblox NPC height)
GameConfig.GRID_SIZE = 2
GameConfig.MAX_BUILD_HEIGHT = 150

-- Resources
GameConfig.Resources = {
	OhioWood = { Name = "Ohio Wood", Color = Color3.fromRGB(139, 90, 43) },
	GyattGranite = { Name = "Gyatt Granite", Color = Color3.fromRGB(128, 128, 128) },
	SkibidiClay = { Name = "Skibidi Clay", Color = Color3.fromRGB(175, 75, 60) },
	SigmaConcrete = { Name = "Sigma Concrete", Color = Color3.fromRGB(160, 160, 165) },
	RizziteAlloy = { Name = "Rizzite Alloy", Color = Color3.fromRGB(0, 200, 255) },
}

-- Basic Building Blocks Registry (Shapes, Sizes, Materials, Costs)
GameConfig.Blocks = {
	-- 🪵 Ohio Wood Series
	WoodCube1x1 = {
		Name = "Wood 1x1 Cube",
		PartClass = "Part",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.Wood,
		Color = Color3.fromRGB(150, 95, 45),
		MaxHP = 50,
		Cost = { OhioWood = 2 },
	},
	WoodBeam1x2 = {
		Name = "Wood 1x2 Beam",
		PartClass = "Part",
		Size = Vector3.new(2, 4, 2),
		Material = Enum.Material.Wood,
		Color = Color3.fromRGB(140, 85, 40),
		MaxHP = 100,
		Cost = { OhioWood = 4 },
	},
	WoodStairs = {
		Name = "Wood Stairs",
		PartClass = "WedgePart",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.Wood,
		Color = Color3.fromRGB(150, 95, 45),
		MaxHP = 60,
		Cost = { OhioWood = 3 },
	},
	WoodHalfWall = {
		Name = "Wood Half-Wall",
		PartClass = "Part",
		Size = Vector3.new(2, 1, 2),
		Material = Enum.Material.Wood,
		Color = Color3.fromRGB(150, 95, 45),
		MaxHP = 30,
		Cost = { OhioWood = 1 },
	},

	-- 🪨 Gyatt Granite / Stone Series
	StoneCube1x1 = {
		Name = "Stone 1x1 Cube",
		PartClass = "Part",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.Cobblestone,
		Color = Color3.fromRGB(110, 110, 115),
		MaxHP = 150,
		Cost = { GyattGranite = 3 },
	},
	StoneBeam1x2 = {
		Name = "Stone 1x2 Beam",
		PartClass = "Part",
		Size = Vector3.new(2, 4, 2),
		Material = Enum.Material.Cobblestone,
		Color = Color3.fromRGB(100, 100, 105),
		MaxHP = 300,
		Cost = { GyattGranite = 5 },
	},
	StoneSlab2x2 = {
		Name = "Stone 2x2 Slab",
		PartClass = "Part",
		Size = Vector3.new(4, 2, 4),
		Material = Enum.Material.Granite,
		Color = Color3.fromRGB(90, 90, 95),
		MaxHP = 400,
		Cost = { GyattGranite = 8 },
	},
	StoneStairs = {
		Name = "Stone Stairs",
		PartClass = "WedgePart",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.Cobblestone,
		Color = Color3.fromRGB(110, 110, 115),
		MaxHP = 180,
		Cost = { GyattGranite = 4 },
	},

	-- 🧱 Skibidi Clay / Brick Series
	ClayBrick1x1 = {
		Name = "Clay Brick 1x1",
		PartClass = "Part",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.Brick,
		Color = Color3.fromRGB(165, 70, 55),
		MaxHP = 120,
		Cost = { SkibidiClay = 3 },
	},
	ClayWall1x2 = {
		Name = "Clay Wall 1x2",
		PartClass = "Part",
		Size = Vector3.new(2, 4, 2),
		Material = Enum.Material.Brick,
		Color = Color3.fromRGB(155, 60, 45),
		MaxHP = 240,
		Cost = { SkibidiClay = 5 },
	},

	-- 🏗️ Sigma Concrete Series
	ConcretePillar = {
		Name = "Concrete Pillar",
		PartClass = "Part",
		Size = Vector3.new(2, 4, 2),
		Material = Enum.Material.Concrete,
		Color = Color3.fromRGB(160, 160, 165),
		MaxHP = 350,
		Cost = { SigmaConcrete = 4 },
	},
	ConcreteSlab = {
		Name = "Concrete 2x2 Slab",
		PartClass = "Part",
		Size = Vector3.new(4, 2, 4),
		Material = Enum.Material.Concrete,
		Color = Color3.fromRGB(150, 150, 155),
		MaxHP = 500,
		Cost = { SigmaConcrete = 6 },
	},

	-- ⚡ Rizzite Shield Series
	RizziteShield1x1 = {
		Name = "Rizzite Shield 1x1",
		PartClass = "Part",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.Neon,
		Color = Color3.fromRGB(0, 220, 255),
		MaxHP = 350,
		Cost = { GyattGranite = 4, RizziteAlloy = 2 },
	},
	SpikeTrap = {
		Name = "Spike Trap",
		PartClass = "Part",
		Size = Vector3.new(2, 1, 2),
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
