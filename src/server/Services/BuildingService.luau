--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))
local GridUtil = require(Shared:WaitForChild("Modules"):WaitForChild("GridUtil"))

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

	-- Create block Instance (Part or WedgePart)
	local partClassName = blockData.PartClass or "Part"
	local part = Instance.new(partClassName) :: BasePart
	part.Name = "Voxel_" .. blockType .. "_" .. key
	part.Size = blockData.Size or Vector3.new(GameConfig.GRID_SIZE, GameConfig.GRID_SIZE, GameConfig.GRID_SIZE)
	part.Position = snappedPos
	part.Anchored = true
	part.Material = blockData.Material
	part.Color = blockData.Color
	part:SetAttribute("BlockType", blockType)
	part:SetAttribute("MaxHP", blockData.MaxHP)
	part:SetAttribute("CurrentHP", blockData.MaxHP)
	if player then
		part:SetAttribute("OwnerUserId", player.UserId)
	end

	part.Parent = blocksFolder
	placedBlocks[key] = part

	print(string.format("[BuildingService] Placed %s (%s) at grid position %s", blockData.Name, partClassName, key))
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

function BuildingService.getPlacedBlocks()
	return placedBlocks
end

return BuildingService
