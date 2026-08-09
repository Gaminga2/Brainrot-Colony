--!strict
local CraftingRecipes = {}

-- Recipe Master Registry
CraftingRecipes.Recipes = {
	-- Terrain Blocks
	GrassBlock1x1 = { { Resource = "SkibidiClay", Amount = 1 } },
	DirtBlock1x1 = { { Resource = "SkibidiClay", Amount = 1 } },

	-- Blocks
	WoodCube1x1 = { { Resource = "OhioWood", Amount = 2 } },
	WoodBeam1x2 = { { Resource = "OhioWood", Amount = 4 } },
	WoodStairs = { { Resource = "OhioWood", Amount = 3 } },
	WoodHalfWall = { { Resource = "OhioWood", Amount = 1 } },
	StoneCube1x1 = { { Resource = "GyattGranite", Amount = 3 } },
	StoneBeam1x2 = { { Resource = "GyattGranite", Amount = 5 } },
	StoneSlab2x2 = { { Resource = "GyattGranite", Amount = 8 } },
	StoneStairs = { { Resource = "GyattGranite", Amount = 4 } },
	ClayBrick1x1 = { { Resource = "SkibidiClay", Amount = 3 } },
	ClayWall1x2 = { { Resource = "SkibidiClay", Amount = 5 } },
	ConcretePillar = { { Resource = "SigmaConcrete", Amount = 4 } },
	ConcreteSlab = { { Resource = "SigmaConcrete", Amount = 6 } },
	RizziteShield1x1 = { { Resource = "GyattGranite", Amount = 4 }, { Resource = "RizziteAlloy", Amount = 2 } },
	SpikeTrap = { { Resource = "OhioWood", Amount = 1 }, { Resource = "GyattGranite", Amount = 2 } },

	-- Buildings
	ArcherTower = { { Resource = "OhioWood", Amount = 15 }, { Resource = "GyattGranite", Amount = 10 } },
	StorageCore = { { Resource = "OhioWood", Amount = 20 } },
	SiegeWorkshop = { { Resource = "GyattGranite", Amount = 30 }, { Resource = "RizziteAlloy", Amount = 10 } },
	CastleGate = { { Resource = "GyattGranite", Amount = 25 } },

	-- Weapons
	RizzSword = { { Resource = "GyattGranite", Amount = 10 }, { Resource = "RizziteAlloy", Amount = 5 } },
	FanumBow = { { Resource = "OhioWood", Amount = 12 } },
	OhioAxe = { { Resource = "OhioWood", Amount = 8 }, { Resource = "GyattGranite", Amount = 5 } },
	SkibidiBomb = { { Resource = "SkibidiClay", Amount = 15 }, { Resource = "RizziteAlloy", Amount = 8 } },
}

-- Format crafting recipe as requested: "resourcename_x(amount)" (e.g. "OhioWood_x2, GyattGranite_x4")
function CraftingRecipes.getFormattedRecipe(itemId: string): string
	local recipe = CraftingRecipes.Recipes[itemId]
	if not recipe or #recipe == 0 then
		return "Free / Default"
	end

	local parts = {}
	for _, req in ipairs(recipe) do
		table.insert(parts, string.format("%s_x%d", req.Resource, req.Amount))
	end

	return table.concat(parts, ", ")
end

return CraftingRecipes
