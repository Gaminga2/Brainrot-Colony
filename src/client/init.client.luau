--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Controllers = script.Parent:WaitForChild("Controllers")
local UI = script.Parent:WaitForChild("UI")
local PlacementController = require(Controllers:WaitForChild("PlacementController"))
local MinionCommandController = require(Controllers:WaitForChild("MinionCommandController"))
local TopNavigationMenu = require(UI:WaitForChild("TopNavigationMenu"))

print("[Client] Initializing Project Brainrot Castle...")

-- Initialize Controllers & UI
PlacementController.init()
MinionCommandController.init()
TopNavigationMenu.init()

-- Create On-Screen HUD Guide for Controls
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui") :: PlayerGui

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotCastleHUD"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Name = "ControlGuideFrame"
frame.Size = UDim2.new(0, 260, 0, 160)
frame.Position = UDim2.new(0, 15, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Text = "🏰 BRAINROT CASTLE (v0.0.1)"
title.Font = Enum.Font.FredokaOne
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Parent = frame

local guideText = Instance.new("TextLabel")
guideText.Text = "• [B] Toggle Placement Mode\n• [Left-Click] Place Voxel Block / Select Minion\n• [Right-Click] Move Selected Minion\n• [M] Spawn Mewing Mason"
guideText.Font = Enum.Font.SourceSansBold
guideText.TextSize = 14
guideText.TextColor3 = Color3.fromRGB(240, 240, 240)
guideText.Size = UDim2.new(1, -20, 1, -40)
guideText.Position = UDim2.new(0, 10, 0, 30)
guideText.TextXAlignment = Enum.TextXAlignment.Left
guideText.TextYAlignment = Enum.TextYAlignment.Top
guideText.BackgroundTransparency = 1
guideText.Parent = frame

screenGui.Parent = playerGui

-- Spawn extra minion hotkey [M]
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.M then
		local spawnRemote = ReplicatedStorage:FindFirstChild("SpawnMinionRequest") :: RemoteFunction
		if spawnRemote then
			local ok = spawnRemote:InvokeServer("MewingMason", "Gigachad")
			if ok then
				print("[Client] Spawned extra Mewing Mason minion!")
			end
		end
	end
end)

print("[Client] Brainrot Castle v0.0.1 HUD Ready!")