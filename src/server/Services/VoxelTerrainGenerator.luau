--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))
local GridUtil = require(Shared:WaitForChild("Modules"):WaitForChild("GridUtil"))
local BlockVisuals = require(Shared:WaitForChild("Modules"):WaitForChild("BlockVisuals"))
local BuildingService = require(script.Parent:WaitForChild("BuildingService"))

local VoxelTerrainGenerator = {}

-- Island Dimensions (32x32 2-stud voxel blocks = 64x64 studs island)
local ISLAND_RADIUS = 16
local BASE_HEIGHT_Y = 2
local NOISE_SCALE = 0.08
local SEED = 1337

function VoxelTerrainGenerator.generateIsland()
	local terrainFolder = Workspace:FindFirstChild("PlacedBlocks") :: Folder
	if not terrainFolder then
		terrainFolder = Instance.new("Folder")
		terrainFolder.Name = "PlacedBlocks"
		terrainFolder.Parent = Workspace
	end

	local count = 0
	for x = -ISLAND_RADIUS, ISLAND_RADIUS do
		for z = -ISLAND_RADIUS, ISLAND_RADIUS do
			-- Circular island shape mask
			local distFromCenter = math.sqrt(x * x + z * z)
			if distFromCenter <= ISLAND_RADIUS then
				-- Calculate natural rolling hills height via 2D Perlin noise
				local noiseVal = math.noise(x * NOISE_SCALE, z * NOISE_SCALE, SEED)
				local heightMultiplier = (1 - (distFromCenter / ISLAND_RADIUS) ^ 2) -- Falloff towards island edges
				local heightBlocks = math.clamp(math.floor(noiseVal * 4 * heightMultiplier) + 3, 1, 8)

				for y = 0, heightBlocks do
					local worldPos = Vector3.new(x * GameConfig.GRID_SIZE, BASE_HEIGHT_Y + (y * GameConfig.GRID_SIZE), z * GameConfig.GRID_SIZE)
					local snappedPos = GridUtil.snapToGrid(worldPos)
					local key = GridUtil.toGridKey(snappedPos)

					-- Determine terrain block material layer
					local blockType = "GrassBlock1x1"
					if y < heightBlocks then
						if y >= heightBlocks - 2 then
							blockType = "DirtBlock1x1"
						else
							blockType = "StoneCube1x1"
						end
					end

					local blockData = GameConfig.Blocks[blockType]
					if blockData then
						local part = Instance.new("Part")
						part.Name = "Voxel_" .. blockType .. "_" .. key
						part.Size = blockData.Size or Vector3.new(GameConfig.GRID_SIZE, GameConfig.GRID_SIZE, GameConfig.GRID_SIZE)
						part.Position = snappedPos
						part.Anchored = true
						part.CanCollide = true
						part.Material = blockData.Material
						part.Color = blockData.Color
						part:SetAttribute("BlockType", blockType)
						part:SetAttribute("MaxHP", blockData.MaxHP)
						part:SetAttribute("CurrentHP", blockData.MaxHP)
						part:SetAttribute("IsTerrain", true)

						-- Apply cute rounded bevel visual engine
						BlockVisuals.applyCuteStyling(part, blockType)

						part.Parent = terrainFolder
						BuildingService.registerGeneratedBlock(part, key)
						count = count + 1
					end
				end
			end
		end
	end

	print(string.format("[VoxelTerrainGenerator] Procedurally generated %d terrain voxel blocks for floating island!", count))
end

function VoxelTerrainGenerator.init()
	VoxelTerrainGenerator.generateIsland()
end

return VoxelTerrainGenerator
