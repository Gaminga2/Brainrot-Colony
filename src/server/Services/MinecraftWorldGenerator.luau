--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))

local MinecraftWorldGenerator = {}

function MinecraftWorldGenerator.generateWorld()
	local terrain = Workspace.Terrain
	if not terrain then
		warn("[MinecraftWorldGenerator] Workspace.Terrain not found!")
		return
	end

	local cfg = GameConfig.TerrainConfig or {
		WORLD_SIZE_STUDS = 160,
		STEP_STUDS = 4,
		BASE_SURFACE_Y = 12,
		HILL_HEIGHT = 18,
		NOISE_SCALE = 0.02,
		SEED = 777,
	}

	-- Clear old terrain if re-generating
	terrain:Clear()

	print("[MinecraftWorldGenerator] Generating smooth Minecraft-style voxel world...")
	local halfSize = cfg.WORLD_SIZE_STUDS / 2
	local step = cfg.STEP_STUDS
	local noiseScale = cfg.NOISE_SCALE
	local seed = cfg.SEED
	local hillHeight = cfg.HILL_HEIGHT or 18
	local baseSurfaceY = cfg.BASE_SURFACE_Y or 12

	for x = -halfSize, halfSize, step do
		for z = -halfSize, halfSize, step do
			-- Circular island boundary mask
			local distFromCenter = math.sqrt(x * x + z * z)
			if distFromCenter <= halfSize then
				local falloff = (1 - (distFromCenter / halfSize) ^ 2)
				local noiseVal = math.noise(x * noiseScale, z * noiseScale, seed)
				local surfaceY = math.floor(baseSurfaceY + (noiseVal * hillHeight * falloff))

				-- 1. Deep Rock Foundation Core (Y = 0 to surfaceY - 8)
				if surfaceY - 8 > 0 then
					local rockCFrame = CFrame.new(x, (surfaceY - 8) / 2, z)
					local rockSize = Vector3.new(step, surfaceY - 8, step)
					terrain:FillBlock(rockCFrame, rockSize, Enum.Material.Rock)
				end

				-- 2. Sub-Layer Dirt (Y = surfaceY - 8 to surfaceY - 2)
				local dirtCFrame = CFrame.new(x, surfaceY - 5, z)
				local dirtSize = Vector3.new(step, 6, step)
				terrain:FillBlock(dirtCFrame, dirtSize, Enum.Material.Ground)

				-- 3. Top Layer Grass (Y = surfaceY - 2 to surfaceY)
				local grassCFrame = CFrame.new(x, surfaceY - 1, z)
				local grassSize = Vector3.new(step, 2, step)
				terrain:FillBlock(grassCFrame, grassSize, Enum.Material.Grass)
			end
		end
	end

	print("[MinecraftWorldGenerator] Minecraft-style Smooth Terrain world generation complete!")
end

function MinecraftWorldGenerator.init()
	if GameConfig.TerrainConfig and GameConfig.TerrainConfig.PRELOAD_TERRAIN_ON_BOOT then
		MinecraftWorldGenerator.generateWorld()
	end
end

return MinecraftWorldGenerator
