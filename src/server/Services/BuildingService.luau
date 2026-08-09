--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))
local GridUtil = require(Shared:WaitForChild("Modules"):WaitForChild("GridUtil"))
local BlockVisuals = require(Shared:WaitForChild("Modules"):WaitForChild("BlockVisuals"))

local BuildingService = {}
local placedBlocks: { [string]: Instance } = {}
local blocksFolder: Folder

function BuildingService.init()
	blocksFolder = Workspace:FindFirstChild("PlacedBlocks") :: Folder
	if not blocksFolder then
		blocksFolder = Instance.new("Folder")
		blocksFolder.Name = "PlacedBlocks"
		blocksFolder.Parent = Workspace
	end
end

-- Validate and place a block on grid
function BuildingService.placeBlock(player: Player?, blockType: string, position: Vector3): boolean
	local blockData = GameConfig.Blocks[blockType]
	if not blockData then
		warn("[BuildingService] Invalid block type:", blockType)
		return false
	end

	local snappedPos = GridUtil.snapToGrid(position)
	local key = GridUtil.toGridKey(snappedPos)

	if placedBlocks[key] then
		warn("[BuildingService] Grid position occupied:", key)
		return false
	end

	-- Height limit check
	if snappedPos.Y > GameConfig.MAX_BUILD_HEIGHT then
		warn("[BuildingService] Exceeded max build height!")
		return false
	end

	-- Environment Interaction Engine: Flatten 3x3 surrounding Smooth Terrain neighborhood around block location
	local terrain = Workspace.Terrain
	if terrain then
		local gs = GameConfig.GRID_SIZE
		local blockSize = blockData.Size or Vector3.new(gs, gs, gs)
		
		-- Clear smooth terrain volume in placed cell AND 3x3 surrounding neighborhood
		terrain:FillBlock(CFrame.new(snappedPos), blockSize + Vector3.new(gs * 2 + 0.2, 0.4, gs * 2 + 0.2), Enum.Material.Air)

		-- Level 3x3 ground neighbor cells directly below into clean blocky voxel foundations
		for dx = -gs, gs, gs do
			for dz = -gs, gs, gs do
				local neighborBelowPos = snappedPos + Vector3.new(dx, -gs, dz)
				local neighborKey = GridUtil.toGridKey(neighborBelowPos)
				if not placedBlocks[neighborKey] and neighborBelowPos.Y > 0 then
					terrain:FillBlock(CFrame.new(neighborBelowPos), Vector3.new(gs + 0.1, gs + 0.1, gs + 0.1), Enum.Material.Air)

					local foundPart = Instance.new("Part")
					foundPart.Name = "Voxel_GrassTopBlock1x1_" .. neighborKey
					foundPart.Size = Vector3.new(gs, gs, gs)
					foundPart.Position = neighborBelowPos
					foundPart.Anchored = true
					foundPart.CanCollide = true
					foundPart:SetAttribute("BlockType", "GrassTopBlock1x1")
					foundPart:SetAttribute("MaxHP", 45)
					foundPart:SetAttribute("CurrentHP", 45)
					BlockVisuals.applyCuteStyling(foundPart, "GrassTopBlock1x1")
					foundPart.Parent = blocksFolder
					placedBlocks[neighborKey] = foundPart
				end
			end
		end
	end

	-- Create block Instance (Part or WedgePart)
	local partClassName = blockData.PartClass or "Part"
	local part = Instance.new(partClassName) :: BasePart
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
	if player then
		part:SetAttribute("OwnerUserId", player.UserId)
	end

	-- Apply Cute Brainrot Block Visuals (Soft Bevels & Derpy Face Decals)
	BlockVisuals.applyCuteStyling(part, blockType)

	part.Parent = blocksFolder
	placedBlocks[key] = part

	print(string.format("[BuildingService] Placed %s (%s) with environment terrain flattening at %s", blockData.Name, partClassName, key))
	return true
end

-- Damage or destroy a block
function BuildingService.damageBlock(position: Vector3, damageAmount: number)
	local key = GridUtil.toGridKey(position)
	local part = placedBlocks[key] :: BasePart?
	if not part then return end

	local currentHP = part:GetAttribute("CurrentHP") or 100
	currentHP = currentHP - damageAmount
	if currentHP <= 0 then
		part:Destroy()
		placedBlocks[key] = nil
		print("[BuildingService] Block destroyed at key:", key)
	else
		part:SetAttribute("CurrentHP", currentHP)
		-- Visual damage feedback
		local ratio = math.clamp(currentHP / (part:GetAttribute("MaxHP") or 100), 0.2, 1)
		part.Transparency = 1 - ratio * 0.8
	end
end

-- Dig/Mine native Smooth Terrain
function BuildingService.digTerrain(position: Vector3, radius: number?)
	local terrain = Workspace.Terrain
	if terrain then
		local rad = radius or 3
		terrain:FillBall(position, rad, Enum.Material.Air)
		print(string.format("[BuildingService] Dug terrain hole at %s (radius: %.1f)", tostring(position), rad))
	end
end

function BuildingService.registerGeneratedBlock(part: BasePart, key: string)
	placedBlocks[key] = part
end

function BuildingService.getPlacedBlocks()
	return placedBlocks
end

return BuildingService
