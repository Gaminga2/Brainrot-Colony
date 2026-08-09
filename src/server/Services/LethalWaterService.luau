--!strict
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LethalWaterService = {}

function LethalWaterService.init()
	task.spawn(function()
		while true do
			task.wait(0.2)

			-- 1. Check Player Characters
			for _, player in ipairs(Players:GetPlayers()) do
				local character = player.Character
				if character then
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					local hrp = character:FindFirstChild("HumanoidRootPart") :: Part?

					if humanoid and humanoid.Health > 0 and hrp then
						-- Kill player if they fall into ocean water (Y <= 5 or Swimming state)
						if hrp.Position.Y <= 5 or humanoid:GetState() == Enum.HumanoidStateType.Swimming then
							humanoid.Health = 0
							print(string.format("[LethalWaterService] Player %s fell into the ocean and was eliminated!", player.Name))
						end
					end
				end
			end

			-- 2. Check Minion Models in Workspace
			local minionsFolder = Workspace:FindFirstChild("BrainrotMinions")
			if minionsFolder then
				for _, minion in ipairs(minionsFolder:GetChildren()) do
					if minion:IsA("Model") then
						local humanoid = minion:FindFirstChildOfClass("Humanoid")
						local primaryPart = minion.PrimaryPart or minion:FindFirstChild("HumanoidRootPart") :: Part?

						if humanoid and humanoid.Health > 0 and primaryPart then
							if primaryPart.Position.Y <= 5 or humanoid:GetState() == Enum.HumanoidStateType.Swimming then
								humanoid.Health = 0
								print(string.format("[LethalWaterService] Minion %s drowned in ocean water!", minion.Name))
							end
						end
					end
				end
			end
		end
	end)

	print("[LethalWaterService] Lethal Ocean Water Border Service initialized!")
end

return LethalWaterService
