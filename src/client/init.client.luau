--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Controllers = script:WaitForChild("Controllers")
local UI = script:WaitForChild("UI")
local PlacementController = require(Controllers:WaitForChild("PlacementController"))
local MinionCommandController = require(Controllers:WaitForChild("MinionCommandController"))
local GhostPlayerController = require(Controllers:WaitForChild("GhostPlayerController"))
local TopNavigationMenu = require(UI:WaitForChild("TopNavigationMenu"))
local SettingsMenu = require(UI:WaitForChild("SettingsMenu"))
local PlayerProfileHUD = require(UI:WaitForChild("PlayerProfileHUD"))

print("[Client] Initializing Project Brainrot Castle...")

-- Initialize Controllers & UI
PlacementController.init()
MinionCommandController.init()
GhostPlayerController.init()
TopNavigationMenu.init()
SettingsMenu.init()
PlayerProfileHUD.init()

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