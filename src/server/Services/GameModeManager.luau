--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))

local GameModeManager = {}
local currentMode: string = GameConfig.GameModes.SURVIVAL
local currentDay: number = 1
local currentWave: number = 1
local isNight: boolean = false

local playerResources: { [number]: {
	Money: number,
	Wave: number,
	OhioWood: number,
	GyattGranite: number,
	SkibidiClay: number,
	SigmaConcrete: number,
	RizziteAlloy: number,
} } = {}

function GameModeManager.init()
	-- Remote Function for Client UI Sync
	local getResRemote = ReplicatedStorage:FindFirstChild("GetPlayerResourcesRequest") :: RemoteFunction
	if not getResRemote then
		getResRemote = Instance.new("RemoteFunction")
		getResRemote.Name = "GetPlayerResourcesRequest"
		getResRemote.Parent = ReplicatedStorage
	end

	getResRemote.OnServerInvoke = function(player: Player)
		return GameModeManager.getResources(player)
	end

	-- Initialize resource balance tracking for joining players
	Players.PlayerAdded:Connect(function(player)
		playerResources[player.UserId] = {
			Money = 500,
			Wave = currentWave,
			OhioWood = 50,
			GyattGranite = 30,
			SkibidiClay = 20,
			SigmaConcrete = 15,
			RizziteAlloy = 10,
		}
		print(string.format("[GameModeManager] Initialized starting resources for %s", player.Name))
	end)

	Players.PlayerRemoving:Connect(function(player)
		playerResources[player.UserId] = nil
	end)
end

function GameModeManager.setGameMode(mode: string)
	if mode == GameConfig.GameModes.SURVIVAL or mode == GameConfig.GameModes.PVP or mode == GameConfig.GameModes.CREATIVE then
		currentMode = mode
		print("[GameModeManager] Switched active mode to:", currentMode)
	end
end

function GameModeManager.getCurrentMode(): string
	return currentMode
end

function GameModeManager.getResources(player: Player)
	local res = playerResources[player.UserId]
	if not res then
		res = {
			Money = 500,
			Wave = currentWave,
			OhioWood = 50,
			GyattGranite = 30,
			SkibidiClay = 20,
			SigmaConcrete = 15,
			RizziteAlloy = 10,
		}
		playerResources[player.UserId] = res
	end
	res.Wave = currentWave
	return res
end

function GameModeManager.addResource(player: Player, resourceName: string, amount: number)
	local res = GameModeManager.getResources(player)
	if res and (res :: any)[resourceName] ~= nil then
		(res :: any)[resourceName] = (res :: any)[resourceName] + amount
		print(string.format("[GameModeManager] Added %d %s to %s", amount, resourceName, player.Name))
	end
end

function GameModeManager.deductResources(player: Player, costTable: { [string]: number }): boolean
	-- Creative mode bypasses resource deduction entirely for free sandbox building!
	if currentMode == GameConfig.GameModes.CREATIVE then
		return true
	end

	local res = GameModeManager.getResources(player)
	if not res then return false end

	for resName, reqAmount in pairs(costTable) do
		if ((res :: any)[resName] or 0) < reqAmount then
			print(string.format("[GameModeManager] Insufficient %s for %s", resName, player.Name))
			return false
		end
	end

	for resName, reqAmount in pairs(costTable) do
		(res :: any)[resName] = (res :: any)[resName] - reqAmount
	end

	return true
end

return GameModeManager
