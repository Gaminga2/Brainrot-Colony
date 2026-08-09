--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameSettings = require(Shared:WaitForChild("Modules"):WaitForChild("GameSettings"))

local GhostPlayerController = {}

local function applyCharacterPhysics(character: Model)
	RunService.Stepped:Connect(function()
		if not character or not character.Parent then return end

		local isGhostMode = GameSettings.get("GhostMode") == true
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
				if isGhostMode then
					child.CanCollide = false
					child.Transparency = 0.35
				else
					child.CanCollide = true
					child.Transparency = 0
				end
			end
		end
	end)
end

function GhostPlayerController.init()
	if LocalPlayer.Character then
		applyCharacterPhysics(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(function(character)
		applyCharacterPhysics(character)
	end)

	print("[GhostPlayerController] Ghost Mode toggle controller initialized!")
end

return GhostPlayerController
