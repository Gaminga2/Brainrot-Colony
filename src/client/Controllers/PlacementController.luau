--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))
local GridUtil = require(Shared:WaitForChild("Modules"):WaitForChild("GridUtil"))

local PlacementController = {}
local ghostPart: BasePart? = nil
local isPlacementActive: boolean = false
local selectedBlockType: string = "WoodCube1x1"

local function createGhostPart(blockType: string): BasePart
	local blockData = GameConfig.Blocks[blockType] or GameConfig.Blocks.WoodCube1x1
	local partClass = blockData.PartClass or "Part"

	local ghost = Instance.new(partClass) :: BasePart
	ghost.Name = "PlacementGhost"
	ghost.Size = blockData.Size or Vector3.new(GameConfig.GRID_SIZE, GameConfig.GRID_SIZE, GameConfig.GRID_SIZE)
	ghost.Anchored = true
	ghost.CanCollide = false
	ghost.Material = Enum.Material.ForceField
	ghost.Color = blockData.Color or Color3.fromRGB(0, 255, 120)
	ghost.Transparency = 0.4
	return ghost
end

function PlacementController.init()
	ghostPart = createGhostPart(selectedBlockType)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		-- Toggle placement mode with B key
		if input.KeyCode == Enum.KeyCode.B then
			PlacementController.togglePlacementMode()
		elseif isPlacementActive and input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Attempt block placement on mouse click
			if Mouse.Target then
				local blockData = GameConfig.Blocks[selectedBlockType]
				local yOffset = blockData and blockData.Size and (blockData.Size.Y / 2) or (GameConfig.GRID_SIZE / 2)
				local targetPos = Mouse.Hit.Position + Vector3.new(0, yOffset, 0)
				local snapped = GridUtil.snapToGrid(targetPos)

				local placeBlockRemote = ReplicatedStorage:FindFirstChild("PlaceBlockRequest") :: RemoteFunction
				if placeBlockRemote then
					local success = placeBlockRemote:InvokeServer(selectedBlockType, snapped)
					if success then
						print("[PlacementController] Successfully placed block:", selectedBlockType)
					else
						warn("[PlacementController] Placement failed.")
					end
				end
			end
		end
	end)
end

function PlacementController.togglePlacementMode()
	isPlacementActive = not isPlacementActive
	if isPlacementActive then
		if ghostPart then ghostPart.Parent = Workspace end
		task.spawn(function()
			while isPlacementActive do
				if Mouse.Hit and ghostPart then
					local blockData = GameConfig.Blocks[selectedBlockType]
					local yOffset = blockData and blockData.Size and (blockData.Size.Y / 2) or (GameConfig.GRID_SIZE / 2)
					local snapPos = GridUtil.snapToGrid(Mouse.Hit.Position + Vector3.new(0, yOffset, 0))
					ghostPart.Position = snapPos
				end
				task.wait(0.03)
			end
			if ghostPart then ghostPart.Parent = nil end
		end)
		print("[PlacementController] Placement Mode: ON (Press B to toggle)")
	else
		if ghostPart then ghostPart.Parent = nil end
		print("[PlacementController] Placement Mode: OFF")
	end
end

function PlacementController.setSelectedBlock(blockType: string)
	if GameConfig.Blocks[blockType] then
		selectedBlockType = blockType
		local wasActive = isPlacementActive
		if ghostPart then
			ghostPart:Destroy()
			ghostPart = nil
		end
		ghostPart = createGhostPart(selectedBlockType)
		if wasActive then
			ghostPart.Parent = Workspace
		end
		print("[PlacementController] Selected Block:", GameConfig.Blocks[blockType].Name)
	end
end

function PlacementController.isPlacementActiveMode(): boolean
	return isPlacementActive
end

return PlacementController
