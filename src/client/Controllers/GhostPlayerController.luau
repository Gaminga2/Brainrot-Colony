--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local GhostPlayerController = {}

local function applyGhostPhysics(character: Model)
	task.wait(0.1)
	for _, child in ipairs(character:GetDescendants()) do
		if child:IsA("BasePart") then
			-- Disable collision so player walks through blocks and structure without bugging physics
			child.CanCollide = false
			-- Apply ghost transparency effect
			if child.Name ~= "HumanoidRootPart" then
				child.Transparency = 0.35
			end
		end
	end

	-- Continuous enforcement loop to prevent physics engine from re-enabling collision
	RunService.Stepped:Connect(function()
		if character and character.Parent then
			for _, child in ipairs(character:GetChildren()) do
				if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
					child.CanCollide = false
				end
			end
		end
	end)
end

function GhostPlayerController.init()
	if LocalPlayer.Character then
		applyGhostPhysics(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(function(character)
		applyGhostPhysics(character)
	end)

	print("[GhostPlayerController] Ghost Commander physics initialized!")
end

return GhostPlayerController
