--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))
local GridUtil = require(Shared:WaitForChild("Modules"):WaitForChild("GridUtil"))
local BlockVisuals = require(Shared:WaitForChild("Modules"):WaitForChild("BlockVisuals"))
local GameSettings = require(Shared:WaitForChild("Modules"):WaitForChild("GameSettings"))

local PlacementController = {}
local ghostPart: BasePart? = nil
local gridOverlayPart: BasePart? = nil
local isPlacementActive: boolean = false
local selectedBlockType: string = "WoodCube1x1"

-- Filtered Raycast Helper: Ignores player character, accessories, minions, ghost preview, and grid overlay
local function getFilteredMouseHit(): Vector3?
	if not Camera then
		Camera = Workspace.CurrentCamera
	end
	if not Camera then return nil end

	local mousePos = UserInputService:GetMouseLocation()
	local unitRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude

	local filterList = {}
	if LocalPlayer.Character then
		table.insert(filterList, LocalPlayer.Character)
	end
	local minionsFolder = Workspace:FindFirstChild("BrainrotMinions")
	if minionsFolder then
		table.insert(filterList, minionsFolder)
	end
	if ghostPart then
		table.insert(filterList, ghostPart)
	end
	if gridOverlayPart then
		table.insert(filterList, gridOverlayPart)
	end

	params.FilterDescendantsInstances = filterList

	local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
	if result then
		return result.Position
	end
	return nil
end

-- Create Visual Blueprint Grid Plane Overlay
local function createGridOverlayPart(): BasePart
	local plane = Instance.new("Part")
	plane.Name = "VisualBlueprintGridOverlay"
	plane.Size = Vector3.new(32, 0.05, 32)
	plane.Anchored = true
	plane.CanCollide = false
	plane.CanTouch = false
	plane.CanQuery = false
	plane.Material = Enum.Material.ForceField
	plane.Color = Color3.fromRGB(0, 180, 255)
	plane.Transparency = 0.55
	return plane
end

-- Create Visual Cyan Blueprint Hologram Preview Ghost
local function createGhostPart(blockType: string): BasePart
	local blockData = GameConfig.Blocks[blockType] or GameConfig.Blocks.WoodCube1x1
	local partClass = blockData.PartClass or "Part"

	local ghost = Instance.new(partClass) :: BasePart
	ghost.Name = "PlacementGhost"
	ghost.Size = blockData.Size or Vector3.new(GameConfig.GRID_SIZE, GameConfig.GRID_SIZE, GameConfig.GRID_SIZE)
	ghost.Anchored = true
	ghost.CanCollide = false
	ghost.CanTouch = false
	ghost.CanQuery = false
	ghost.Material = Enum.Material.ForceField
	ghost.Color = Color3.fromRGB(0, 190, 255) -- Cyan Blueprint Hologram Color
	ghost.Transparency = 0.35

	-- Apply Soft Bevel Mesh
	if partClass == "Part" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Brick
		mesh.Scale = Vector3.new(0.98, 0.98, 0.98)
		mesh.Parent = ghost
	end

	return ghost
end

function PlacementController.init()
	ghostPart = createGhostPart(selectedBlockType)
	gridOverlayPart = createGridOverlayPart()

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		-- Toggle placement mode with B key
		if input.KeyCode == Enum.KeyCode.B then
			PlacementController.togglePlacementMode()
		elseif isPlacementActive and input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Attempt block placement on mouse click
			local hitPos = getFilteredMouseHit() or (Mouse.Hit and Mouse.Hit.Position)
			if hitPos then
				local blockData = GameConfig.Blocks[selectedBlockType]
				local yOffset = blockData and blockData.Size and (blockData.Size.Y / 2) or (GameConfig.GRID_SIZE / 2)
				local targetPos = hitPos + Vector3.new(0, yOffset, 0)
				local snapped = GridUtil.snapToGrid(targetPos)

				local placeBlockRemote = ReplicatedStorage:FindFirstChild("PlaceBlockRequest") :: RemoteFunction
				if placeBlockRemote then
					local success = placeBlockRemote:InvokeServer(selectedBlockType, snapped)
					if success then
						print("[PlacementController] Successfully placed blueprint block:", selectedBlockType)
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
		if gridOverlayPart then gridOverlayPart.Parent = Workspace end

		task.spawn(function()
			while isPlacementActive do
				local hitPos = getFilteredMouseHit() or (Mouse.Hit and Mouse.Hit.Position)
				if hitPos and ghostPart then
					local blockData = GameConfig.Blocks[selectedBlockType]
					local yOffset = blockData and blockData.Size and (blockData.Size.Y / 2) or (GameConfig.GRID_SIZE / 2)
					local snapPos = GridUtil.snapToGrid(hitPos + Vector3.new(0, yOffset, 0))

					-- Move ghost block preview
					if GameSettings.get("SmoothGridSnapping") then
						ghostPart.Position = ghostPart.Position:Lerp(snapPos, GameSettings.get("GridLerpSpeed") or 0.35)
					else
						ghostPart.Position = snapPos
					end

					-- Move 3D visual blueprint grid plane directly under cursor
					if gridOverlayPart then
						local gridCenter = GridUtil.snapToGrid(hitPos)
						gridOverlayPart.Position = Vector3.new(gridCenter.X, hitPos.Y + 0.02, gridCenter.Z)
					end
				end
				task.wait(0.03)
			end

			if ghostPart then ghostPart.Parent = nil end
			if gridOverlayPart then gridOverlayPart.Parent = nil end
		end)
		print("[PlacementController] Visual Blueprint Build Mode: ON (Press B to toggle)")
	else
		if ghostPart then ghostPart.Parent = nil end
		if gridOverlayPart then gridOverlayPart.Parent = nil end
		print("[PlacementController] Visual Blueprint Build Mode: OFF")
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
		print("[PlacementController] Selected Blueprint Block:", GameConfig.Blocks[blockType].Name)
	end
end

function PlacementController.isPlacementActiveMode(): boolean
	return isPlacementActive
end

return PlacementController
