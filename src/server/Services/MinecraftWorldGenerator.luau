--!strict
local Workspace = game:GetService("Workspace")

local MinecraftWorldGenerator = {}

-- Island Dimensions (128x128 studs Minecraft-style world)
local WORLD_SIZE_STUDS = 128
local STEP_STUDS = 4
local BASE_SURFACE_Y = 12
local NOISE_SCALE = 0.025
local SEED = 777

function MinecraftWorldGenerator.generateWorld()
	local terrain = Workspace.Terrain
	if not terrain then
		warn("[MinecraftWorldGenerator] Workspace.Terrain not found!")
		return
	end

	-- Clear old terrain if any
	terrain:Clear()

	print("[MinecraftWorldGenerator] Generating smooth Minecraft-style voxel world...")
	local halfSize = WORLD_SIZE_STUDS / 2

	for x = -halfSize, halfSize, STEP_STUDS do
		for z = -halfSize, halfSize, STEP_STUDS do
			-- Circular island boundary mask
			local distFromCenter = math.sqrt(x * x + z * z)
			if distFromCenter <= halfSize then
				local falloff = (1 - (distFromCenter / halfSize) ^ 2)
				local noiseVal = math.noise(x * NOISE_SCALE, z * NOISE_SCALE, SEED)
				local surfaceY = math.floor(BASE_SURFACE_Y + (noiseVal * 16 * falloff))

				-- 1. Deep Rock Foundation Core (Y = 0 to surfaceY - 8)
				if surfaceY - 8 > 0 then
					local rockCFrame = CFrame.new(x, (surfaceY - 8) / 2, z)
					local rockSize = Vector3.new(STEP_STUDS, surfaceY - 8, STEP_STUDS)
					terrain:FillBlock(rockCFrame, rockSize, Enum.Material.Rock)
				end

				-- 2. Sub-Layer Dirt (Y = surfaceY - 8 to surfaceY - 2)
				local dirtCFrame = CFrame.new(x, surfaceY - 5, z)
				local dirtSize = Vector3.new(STEP_STUDS, 6, STEP_STUDS)
				terrain:FillBlock(dirtCFrame, dirtSize, Enum.Material.Dirt)

				-- 3. Top Layer Grass (Y = surfaceY - 2 to surfaceY)
				local grassCFrame = CFrame.new(x, surfaceY - 1, z)
				local grassSize = Vector3.new(STEP_STUDS, 2, STEP_STUDS)
				terrain:FillBlock(grassCFrame, grassSize, Enum.Material.Grass)
			end
		end
	end

	print("[MinecraftWorldGenerator] Minecraft-style Smooth Terrain world generation complete!")
end

function MinecraftWorldGenerator.init()
	MinecraftWorldGenerator.generateWorld()
end

return MinecraftWorldGenerator
