--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local MinionCommandController = {}
local selectedMinion: Model? = nil

function MinionCommandController.init()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		-- Right click to command minion movement
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			if selectedMinion and Mouse.Hit then
				local commandMoveRemote = ReplicatedStorage:FindFirstChild("CommandMinionMove") :: RemoteEvent
				if commandMoveRemote then
					commandMoveRemote:FireServer(selectedMinion, Mouse.Hit.Position)
					print("[MinionCommandController] Commanded minion move to:", Mouse.Hit.Position)
				end
			end

		-- Left click on minion to select
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			local target = Mouse.Target
			if target and target.Parent then
				local model = target.Parent :: Model
				if model:GetAttribute("MinionClass") and model:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
					selectedMinion = model
					print("[MinionCommandController] Selected Minion:", model.Name)
				end
			end
		end
	end)
end

function MinionCommandController.getSelectedMinion()
	return selectedMinion
end

return MinionCommandController
