--!strict
local GameConfig = {}

-- Project Metadata
GameConfig.PROJECT_NAME = "Brainrot Castle (Brainrot Colony)"
GameConfig.VERSION = "v0.0.23"

-- Voxel Snap Grid Configuration (2x2x2 studs = ~1/3 Roblox NPC height)
GameConfig.GRID_SIZE = 2
GameConfig.MAX_BUILD_HEIGHT = 150

-- Resources (Pastel Cute Palette)
GameConfig.Resources = {
	OhioWood = { Name = "Ohio Wood", Color = Color3.fromRGB(220, 160, 100) },
	GyattGranite = { Name = "Gyatt Granite", Color = Color3.fromRGB(180, 205, 215) },
	SkibidiClay = { Name = "Skibidi Clay", Color = Color3.fromRGB(235, 130, 130) },
	SigmaConcrete = { Name = "Sigma Concrete", Color = Color3.fromRGB(200, 195, 210) },
	RizziteAlloy = { Name = "Rizzite Alloy", Color = Color3.fromRGB(120, 240, 255) },
}

-- Basic Building Blocks Registry (Cute Soft Block Palette)
GameConfig.Blocks = {
	-- 🌿 Natural Terrain Voxel Blocks
	GrassBlock1x1 = {
		Name = "Grass Block",
		PartClass = "Part",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.Grass,
		Color = Color3.fromRGB(100, 185, 75),
		MaxHP = 40,
		Cost = { SkibidiClay = 1 },
	},
	DirtBlock1x1 = {
		Name = "Dirt Block",
		PartClass = "Part",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.Ground,
		Color = Color3.fromRGB(135, 90, 50),
		MaxHP = 30,
		Cost = { SkibidiClay = 1 },
	},
	-- 🪵 Ohio Wood Series (Soft Caramel Timber)
	WoodCube1x1 = {
		Name = "Wood 1x1 Cube",
		PartClass = "Part",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.Wood,
		Color = Color3.fromRGB(220, 160, 100),
		MaxHP = 50,
		Cost = { OhioWood = 2 },
	},
	WoodBeam1x2 = {
		Name = "Wood 1x2 Beam",
		PartClass = "Part",
		Size = Vector3.new(2, 4, 2),
		Material = Enum.Material.Wood,
		Color = Color3.fromRGB(205, 145, 85),
		MaxHP = 100,
		Cost = { OhioWood = 4 },
	},
	WoodStairs = {
		Name = "Wood Stairs",
		PartClass = "WedgePart",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.Wood,
		Color = Color3.fromRGB(220, 160, 100),
		MaxHP = 60,
		Cost = { OhioWood = 3 },
	},
	WoodHalfWall = {
		Name = "Wood Half-Wall",
		PartClass = "Part",
		Size = Vector3.new(2, 1, 2),
		Material = Enum.Material.Wood,
		Color = Color3.fromRGB(225, 165, 105),
		MaxHP = 30,
		Cost = { OhioWood = 1 },
	},

	-- 🪨 Gyatt Granite / Stone Series (Cute Soft Mint/Periwinkle Stone)
	StoneCube1x1 = {
		Name = "Stone 1x1 Cube",
		PartClass = "Part",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(180, 205, 215),
		MaxHP = 150,
		Cost = { GyattGranite = 3 },
	},
	StoneBeam1x2 = {
		Name = "Stone 1x2 Beam",
		PartClass = "Part",
		Size = Vector3.new(2, 4, 2),
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(165, 190, 200),
		MaxHP = 300,
		Cost = { GyattGranite = 5 },
	},
	StoneSlab2x2 = {
		Name = "Stone 2x2 Slab",
		PartClass = "Part",
		Size = Vector3.new(4, 2, 4),
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(160, 185, 195),
		MaxHP = 400,
		Cost = { GyattGranite = 8 },
	},
	StoneStairs = {
		Name = "Stone Stairs",
		PartClass = "WedgePart",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(180, 205, 215),
		MaxHP = 180,
		Cost = { GyattGranite = 4 },
	},

	-- 🧱 Skibidi Clay / Brick Series (Soft Strawberry Pink Brick)
	ClayBrick1x1 = {
		Name = "Clay Brick 1x1",
		PartClass = "Part",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(235, 130, 130),
		MaxHP = 120,
		Cost = { SkibidiClay = 3 },
	},
	ClayWall1x2 = {
		Name = "Clay Wall 1x2",
		PartClass = "Part",
		Size = Vector3.new(2, 4, 2),
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(220, 115, 115),
		MaxHP = 240,
		Cost = { SkibidiClay = 5 },
	},

	-- 🏗️ Sigma Concrete Series (Cute Soft Lavender Concrete)
	ConcretePillar = {
		Name = "Concrete Pillar",
		PartClass = "Part",
		Size = Vector3.new(2, 4, 2),
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(200, 195, 210),
		MaxHP = 350,
		Cost = { SigmaConcrete = 4 },
	},
	ConcreteSlab = {
		Name = "Concrete 2x2 Slab",
		PartClass = "Part",
		Size = Vector3.new(4, 2, 4),
		Material = Enum.Material.SmoothPlastic,
		Color = Color3.fromRGB(185, 180, 195),
		MaxHP = 500,
		Cost = { SigmaConcrete = 6 },
	},

	-- ⚡ Rizzite Shield Series (Soft Pastel Cyan Glow)
	RizziteShield1x1 = {
		Name = "Rizzite Shield 1x1",
		PartClass = "Part",
		Size = Vector3.new(2, 2, 2),
		Material = Enum.Material.Neon,
		Color = Color3.fromRGB(120, 240, 255),
		MaxHP = 350,
		Cost = { GyattGranite = 4, RizziteAlloy = 2 },
	},
	SpikeTrap = {
		Name = "Spike Trap",
		PartClass = "Part",
		Size = Vector3.new(2, 1, 2),
		Material = Enum.Material.Metal,
		Color = Color3.fromRGB(240, 180, 80),
		MaxHP = 80,
		Cost = { OhioWood = 1, GyattGranite = 2 },
		Damage = 25,
	},
}

-- Game Modes
GameConfig.GameModes = {
	SURVIVAL = "Survival",
	PVP = "PvP",
	CREATIVE = "Creative",
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
