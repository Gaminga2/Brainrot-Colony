--!strict
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local MinionTypes = require(Shared:WaitForChild("Modules"):WaitForChild("MinionTypes"))

local MinionAIService = {}
local activeMinions: { [string]: { Model: Model, Class: string, State: string, Target: Vector3? } } = {}
local minionsFolder: Folder

function MinionAIService.init()
	minionsFolder = Workspace:FindFirstChild("BrainrotMinions") :: Folder
	if not minionsFolder then
		minionsFolder = Instance.new("Folder")
		minionsFolder.Name = "BrainrotMinions"
		minionsFolder.Parent = Workspace
	end
end

-- Spawn a Brainrot Minion
function MinionAIService.spawnMinion(ownerPlayer: Player, minionClass: string, spawnPos: Vector3, skinName: string?): Model?
	local classData = MinionTypes.Classes[minionClass]
	if not classData then
		warn("[MinionAIService] Unknown minion class:", minionClass)
		return nil
	end

	-- Simple R15/R6 blocky NPC construction
	local model = Instance.new("Model")
	model.Name = classData.Name .. "_" .. ownerPlayer.Name

	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Size = Vector3.new(2, 2, 1)
	hrp.Position = spawnPos + Vector3.new(0, 3, 0)
	hrp.CanCollide = true
	hrp.Anchored = false
	hrp.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.2, 1.2, 1.2)
	head.Position = hrp.Position + Vector3.new(0, 1.6, 0)
	head.Color = Color3.fromRGB(255, 220, 180)
	head.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hrp
	weld.Part1 = head
	weld.Parent = hrp

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.MaxHealth = classData.MaxHP
	humanoid.Health = classData.MaxHP
	humanoid.WalkSpeed = classData.WalkSpeed
	humanoid.Parent = model

	model.PrimaryPart = hrp
	model:SetAttribute("OwnerUserId", ownerPlayer.UserId)
	model:SetAttribute("MinionClass", minionClass)
	model:SetAttribute("State", "Idle")

	if skinName and MinionTypes.Skins[skinName] then
		model:SetAttribute("AppliedSkin", skinName)
		print(string.format("[MinionAIService] Applied skin '%s' to %s", skinName, model.Name))
	end

	model.Parent = minionsFolder

	local minionId = model:GetDebugId()
	activeMinions[minionId] = {
		Model = model,
		Class = minionClass,
		State = "Idle",
		Target = nil,
	}

	-- Voice line chatter on spawn!
	local voiceLines = classData.VoiceLines
	if voiceLines and #voiceLines > 0 then
		local randomLine = voiceLines[math.random(1, #voiceLines)]
		print(string.format("[%s says]: %s", classData.Name, randomLine))
	end

	return model
end

-- Command Minion to Move to Target
function MinionAIService.commandMove(minionModel: Model, targetPos: Vector3)
	local humanoid = minionModel:FindFirstChildOfClass("Humanoid")
	local hrp = minionModel.PrimaryPart
	if not humanoid or not hrp then return end

	minionModel:SetAttribute("State", "Moving")

	task.spawn(function()
		local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5 })
		local success, err = pcall(function()
			path:ComputeAsync(hrp.Position, targetPos)
		end)

		if success and path.Status == Enum.PathStatus.Success then
			local waypoints = path:GetWaypoints()
			for _, waypoint in ipairs(waypoints) do
				humanoid:MoveTo(waypoint.Position)
				local reached = humanoid.MoveToFinished:Wait()
				if not reached then break end
			end
		else
			-- Fallback direct move
			humanoid:MoveTo(targetPos)
		end

		minionModel:SetAttribute("State", "Idle")
	end)
end

return MinionAIService
