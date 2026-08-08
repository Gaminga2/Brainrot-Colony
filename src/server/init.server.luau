--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Services = script.Parent:WaitForChild("Services")

local BuildingService = require(Services:WaitForChild("BuildingService"))
local MinionAIService = require(Services:WaitForChild("MinionAIService"))
local GameModeManager = require(Services:WaitForChild("GameModeManager"))

print("[Server] Initializing Project Brainrot Castle (v0.0.1)...")

-- Initialize Services
BuildingService.init()
MinionAIService.init()
GameModeManager.init()

-- Create Remote Events & Functions for Client/Server Communication
local placeBlockRemote = ReplicatedStorage:FindFirstChild("PlaceBlockRequest") :: RemoteFunction
if not placeBlockRemote then
	placeBlockRemote = Instance.new("RemoteFunction")
	placeBlockRemote.Name = "PlaceBlockRequest"
	placeBlockRemote.Parent = ReplicatedStorage
end

local commandMoveRemote = ReplicatedStorage:FindFirstChild("CommandMinionMove") :: RemoteEvent
if not commandMoveRemote then
	commandMoveRemote = Instance.new("RemoteEvent")
	commandMoveRemote.Name = "CommandMinionMove"
	commandMoveRemote.Parent = ReplicatedStorage
end

local spawnMinionRemote = ReplicatedStorage:FindFirstChild("SpawnMinionRequest") :: RemoteFunction
if not spawnMinionRemote then
	spawnMinionRemote = Instance.new("RemoteFunction")
	spawnMinionRemote.Name = "SpawnMinionRequest"
	spawnMinionRemote.Parent = ReplicatedStorage
end

-- Remote Handlers
placeBlockRemote.OnServerInvoke = function(player: Player, blockType: string, position: Vector3)
	-- Deduct resources if required
	local blockData = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig")).Blocks[blockType]
	if blockData and blockData.Cost then
		local hasRes = GameModeManager.deductResources(player, blockData.Cost)
		if not hasRes then
			warn("[Server] Player lacks resources for placement:", player.Name)
			return false
		end
	end

	return BuildingService.placeBlock(player, blockType, position)
end

commandMoveRemote.OnServerEvent:Connect(function(player: Player, minionModel: Model, targetPos: Vector3)
	if minionModel and minionModel:GetAttribute("OwnerUserId") == player.UserId then
		MinionAIService.commandMove(minionModel, targetPos)
	end
end)

spawnMinionRemote.OnServerInvoke = function(player: Player, minionClass: string, skinName: string?)
	local character = player.Character
	if character and character.PrimaryPart then
		local spawnPos = character.PrimaryPart.Position + Vector3.new(0, 0, 5)
		local minion = MinionAIService.spawnMinion(player, minionClass, spawnPos, skinName)
		return minion ~= nil
	end
	return false
end

-- Player Joined Setup: Give Starter Brainrot Minion
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(2)
		local hrp = character:WaitForChild("HumanoidRootPart", 5) :: Part
		if hrp then
			-- Spawn starter Mewing Mason
			MinionAIService.spawnMinion(player, "MewingMason", hrp.Position + Vector3.new(3, 0, 3), "Gigachad")
			print("[Server] Spawned starter Mewing Mason for", player.Name)
		end
	end)
end)

print("[Server] Brainrot Castle v0.0.1 successfully loaded!")