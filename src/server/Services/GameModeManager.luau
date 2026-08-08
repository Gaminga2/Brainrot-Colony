--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))

local GameModeManager = {}
local currentMode: string = GameConfig.GameModes.SURVIVAL
local currentDay: number = 1
local isNight: boolean = false
local playerResources: { [number]: { OhioWood: number, GyattGranite: number, RizziteAlloy: number } } = {}

function GameModeManager.init()
	-- Initialize resource balance tracking for joining players
	Players.PlayerAdded:Connect(function(player)
		playerResources[player.UserId] = {
			OhioWood = 50, -- Starter resources
			GyattGranite = 30,
			RizziteAlloy = 10,
		}
		print(string.format("[GameModeManager] Initialized starting resources for %s", player.Name))
	end)

	Players.PlayerRemoving:Connect(function(player)
		playerResources[player.UserId] = nil
	end)
end

function GameModeManager.setGameMode(mode: string)
	if mode == GameConfig.GameModes.SURVIVAL or mode == GameConfig.GameModes.PVP then
		currentMode = mode
		print("[GameModeManager] Switched active mode to:", currentMode)
	end
end

function GameModeManager.getCurrentMode(): string
	return currentMode
end

function GameModeManager.getResources(player: Player)
	return playerResources[player.UserId] or { OhioWood = 0, GyattGranite = 0, RizziteAlloy = 0 }
end

function GameModeManager.addResource(player: Player, resourceName: string, amount: number)
	local res = playerResources[player.UserId]
	if res and res[resourceName] ~= nil then
		res[resourceName] = res[resourceName] + amount
		print(string.format("[GameModeManager] Added %d %s to %s", amount, resourceName, player.Name))
	end
end

function GameModeManager.deductResources(player: Player, costTable: { [string]: number }): boolean
	local res = playerResources[player.UserId]
	if not res then return false end

	for resName, reqAmount in pairs(costTable) do
		if (res[resName] or 0) < reqAmount then
			print(string.format("[GameModeManager] Insufficient %s for %s", resName, player.Name))
			return false
		end
	end

	for resName, reqAmount in pairs(costTable) do
		res[resName] = res[resName] - reqAmount
	end

	return true
end

return GameModeManager
