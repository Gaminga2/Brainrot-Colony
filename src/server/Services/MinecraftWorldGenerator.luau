--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))

local MinecraftWorldGenerator = {}

local function setupIslandSpawnLocation(baseSurfaceY: number, hillHeight: number, noiseScale: number, seed: number)
	local centerNoise = math.noise(0, 0, seed)
	local centerSurfaceY = math.floor(baseSurfaceY + (centerNoise * hillHeight))

	local spawnLocation = Workspace:FindFirstChild("IslandSpawnLocation") :: SpawnLocation?
	if not spawnLocation then
		spawnLocation = Instance.new("SpawnLocation")
		spawnLocation.Name = "IslandSpawnLocation"
		spawnLocation.Size = Vector3.new(12, 1, 12)
		spawnLocation.Anchored = true
		spawnLocation.CanCollide = false -- Non-colliding ghost spawn plate
		spawnLocation.Neutral = true
		spawnLocation.Duration = 0
		spawnLocation.Transparency = 1 -- Fully invisible spawn marker
		spawnLocation.Parent = Workspace
	end

	spawnLocation.CFrame = CFrame.new(0, centerSurfaceY + 2, 0)
	print(string.format("[MinecraftWorldGenerator] Positioned invisible ghost IslandSpawnLocation at Y = %d", centerSurfaceY + 2))
end

function MinecraftWorldGenerator.generateWorld()
	local terrain = Workspace.Terrain
	if not terrain then
		warn("[MinecraftWorldGenerator] Workspace.Terrain not found!")
		return
	end

	local cfg = GameConfig.TerrainConfig or {
		WORLD_SIZE_STUDS = 320,
		STEP_STUDS = 4,
		BASE_SURFACE_Y = 12,
		HILL_HEIGHT = 18,
		NOISE_SCALE = 0.015,
		SEED = 777,
	}

	-- Clear old terrain if re-generating
	terrain:Clear()

	print("[MinecraftWorldGenerator] Generating 2x smooth Minecraft-style voxel world (320 studs) with surrounding ocean...")
	local halfSize = cfg.WORLD_SIZE_STUDS / 2
	local step = cfg.STEP_STUDS
	local noiseScale = cfg.NOISE_SCALE
	local seed = cfg.SEED
	local hillHeight = cfg.HILL_HEIGHT or 18
	local baseSurfaceY = cfg.BASE_SURFACE_Y or 12

	local maxRadius = halfSize + 120 -- Surrounding lethal ocean border radius

	for x = -maxRadius, maxRadius, step do
		for z = -maxRadius, maxRadius, step do
			local distFromCenter = math.sqrt(x * x + z * z)
			if distFromCenter <= halfSize then
				-- Island Terrain
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
			elseif distFromCenter <= maxRadius then
				-- Surrounding Ocean Water Border (Y = 0 to Y = 6)
				local waterCFrame = CFrame.new(x, 3, z)
				local waterSize = Vector3.new(step, 6, step)
				terrain:FillBlock(waterCFrame, waterSize, Enum.Material.Water)
			end
		end
	end

	-- Create / position central top surface invisible SpawnLocation
	setupIslandSpawnLocation(baseSurfaceY, hillHeight, noiseScale, seed)

	print("[MinecraftWorldGenerator] 2x Minecraft-style Smooth Terrain world & ocean border complete!")
end

function MinecraftWorldGenerator.init()
	if GameConfig.TerrainConfig and GameConfig.TerrainConfig.PRELOAD_TERRAIN_ON_BOOT then
		MinecraftWorldGenerator.generateWorld()
	end
end

return MinecraftWorldGenerator
