--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local PlayerProfileHUD = {}
local containerFrame: Frame? = nil
local nameLabel: TextLabel? = nil
local statusLabel: TextLabel? = nil
local resourceLabels: { [string]: TextLabel } = {}

function PlayerProfileHUD.init()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10) :: PlayerGui?
	if not playerGui then return end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PlayerProfileHUDGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 90
	screenGui.IgnoreGuiInset = true

	-- Profile HUD Container (220px wide x 175px high, top-left under gear button)
	containerFrame = Instance.new("Frame")
	containerFrame.Name = "ProfileContainer"
	containerFrame.Size = UDim2.new(0, 220, 0, 175)
	containerFrame.Position = UDim2.new(0, 15, 0, 80)
	containerFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
	containerFrame.BackgroundTransparency = 0.35
	containerFrame.BorderSizePixel = 0
	containerFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = containerFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(120, 160, 200)
	stroke.Transparency = 0.6
	stroke.Thickness = 1
	stroke.Parent = containerFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = containerFrame

	-- 1. BIG Player Name Header
	nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "PlayerNameHeader"
	nameLabel.Text = string.upper(LocalPlayer.DisplayName or LocalPlayer.Name)
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.TextSize = 18
	nameLabel.TextColor3 = Color3.fromRGB(245, 245, 255)
	nameLabel.Size = UDim2.new(1, 0, 0, 22)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = containerFrame

	-- 2. Money | Wave Status Line
	statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLine"
	statusLabel.Text = "$ 500  |  Wave 1"
	statusLabel.Font = Enum.Font.SourceSansBold
	statusLabel.TextSize = 12
	statusLabel.TextColor3 = Color3.fromRGB(0, 230, 160)
	statusLabel.Size = UDim2.new(1, 0, 0, 16)
	statusLabel.Position = UDim2.new(0, 0, 0, 24)
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.BackgroundTransparency = 1
	statusLabel.Parent = containerFrame

	-- Divider Line
	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.new(0, 0, 0, 44)
	divider.BackgroundColor3 = Color3.fromRGB(80, 110, 140)
	divider.BackgroundTransparency = 0.5
	divider.BorderSizePixel = 0
	divider.Parent = containerFrame

	-- 3. Personal Material Resources List
	local resContainer = Instance.new("Frame")
	resContainer.Size = UDim2.new(1, 0, 1, -48)
	resContainer.Position = UDim2.new(0, 0, 0, 48)
	resContainer.BackgroundTransparency = 1
	resContainer.Parent = containerFrame

	local resLayout = Instance.new("UIListLayout")
	resLayout.FillDirection = Enum.FillDirection.Vertical
	resLayout.SortOrder = Enum.SortOrder.LayoutOrder
	resLayout.Padding = UDim.new(0, 2)
	resLayout.Parent = resContainer

	local materials = {
		{ ID = "OhioWood", Name = "Ohio Wood", Color = Color3.fromRGB(220, 160, 100) },
		{ ID = "GyattGranite", Name = "Gyatt Granite", Color = Color3.fromRGB(180, 205, 215) },
		{ ID = "SkibidiClay", Name = "Skibidi Clay", Color = Color3.fromRGB(235, 130, 130) },
		{ ID = "SigmaConcrete", Name = "Sigma Concrete", Color = Color3.fromRGB(200, 195, 210) },
		{ ID = "RizziteAlloy", Name = "Rizzite Alloy", Color = Color3.fromRGB(120, 240, 255) },
	}

	for idx, mat in ipairs(materials) do
		local matLabel = Instance.new("TextLabel")
		matLabel.Name = "Mat_" .. mat.ID
		matLabel.LayoutOrder = idx
		matLabel.Text = string.format("%s: --", mat.Name)
		matLabel.Font = Enum.Font.SourceSansBold
		matLabel.TextSize = 11
		matLabel.TextColor3 = mat.Color
		matLabel.Size = UDim2.new(1, 0, 0, 16)
		matLabel.TextXAlignment = Enum.TextXAlignment.Left
		matLabel.BackgroundTransparency = 1
		matLabel.Parent = resContainer

		resourceLabels[mat.ID] = matLabel
	end

	-- Periodic Live Inventory Sync Loop (every 0.5s)
	task.spawn(function()
		local getResRemote = ReplicatedStorage:WaitForChild("GetPlayerResourcesRequest", 10) :: RemoteFunction?
		while true do
			if getResRemote then
				local resData = getResRemote:InvokeServer()
				if resData then
					statusLabel.Text = string.format("$ %d  |  Wave %d", resData.Money or 500, resData.Wave or 1)
					for matID, label in pairs(resourceLabels) do
						local matName = (matID == "OhioWood" and "Ohio Wood") or (matID == "GyattGranite" and "Gyatt Granite") or (matID == "SkibidiClay" and "Skibidi Clay") or (matID == "SigmaConcrete" and "Sigma Concrete") or "Rizzite Alloy"
						local amt = resData[matID] or 0
						label.Text = string.format("%s: %d", matName, amt)
					end
				end
			end
			task.wait(0.5)
		end
	end)

	screenGui.Parent = playerGui
	print("[PlayerProfileHUD] Initialized Personal Player Profile & Material Resources HUD!")
end

return PlayerProfileHUD
