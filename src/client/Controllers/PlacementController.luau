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
local ghostPart: Part? = nil
local isPlacementActive: boolean = false
local selectedBlockType: string = "WoodWall"

function PlacementController.init()
	-- Create visual semi-transparent ghost box for placement feedback
	ghostPart = Instance.new("Part")
	ghostPart.Name = "PlacementGhost"
	ghostPart.Size = Vector3.new(GameConfig.GRID_SIZE, GameConfig.GRID_SIZE, GameConfig.GRID_SIZE)
	ghostPart.Anchored = true
	ghostPart.CanCollide = false
	ghostPart.Material = Enum.Material.ForceField
	ghostPart.Color = Color3.fromRGB(0, 255, 120)
	ghostPart.Transparency = 0.5
	ghostPart.Parent = nil

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		-- Toggle placement mode with B key
		if input.KeyCode == Enum.KeyCode.B then
			PlacementController.togglePlacementMode()
		elseif isPlacementActive and input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Attempt block placement on mouse click
			if Mouse.Target then
				local targetPos = Mouse.Hit.Position + Vector3.new(0, GameConfig.GRID_SIZE / 2, 0)
				local snapped = GridUtil.snapToGrid(targetPos)

				local placeBlockRemote = ReplicatedStorage:FindFirstChild("PlaceBlockRequest") :: RemoteFunction
				if placeBlockRemote then
					local success = placeBlockRemote:InvokeServer(selectedBlockType, snapped)
					if success then
						print("[PlacementController] Successfully placed block!")
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
					local snapPos = GridUtil.snapToGrid(Mouse.Hit.Position + Vector3.new(0, GameConfig.GRID_SIZE / 2, 0))
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
	end
end

function PlacementController.isPlacementActiveMode(): boolean
	return isPlacementActive
end

return PlacementController
