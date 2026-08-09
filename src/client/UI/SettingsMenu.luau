--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))
local GameSettings = require(Shared:WaitForChild("Modules"):WaitForChild("GameSettings"))

local SettingsMenu = {}
local modalFrame: Frame? = nil
local isVisible: boolean = false
local activeSideCategory: string = "GameModes"
local rightContentFrame: Frame? = nil

local SideCategories = {
	{ ID = "GameModes", Name = "Game Modes" },
	{ ID = "DevCheats", Name = "Developer Cheats" },
	{ ID = "GridSettings", Name = "Grid & Building" },
	{ ID = "AudioVisuals", Name = "Audio & Visuals" },
}

function SettingsMenu.init()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10) :: PlayerGui?
	if not playerGui then return end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SettingsMenuGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 150
	screenGui.IgnoreGuiInset = true

	-- Center Modal Window Container (520px x 320px)
	modalFrame = Instance.new("Frame")
	modalFrame.Name = "SettingsModal"
	modalFrame.Size = UDim2.new(0, 520, 0, 320)
	modalFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
	modalFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
	modalFrame.BackgroundTransparency = 0.2
	modalFrame.BorderSizePixel = 0
	modalFrame.Visible = false
	modalFrame.Parent = screenGui

	local modalCorner = Instance.new("UICorner")
	modalCorner.CornerRadius = UDim.new(0, 10)
	modalCorner.Parent = modalFrame

	local modalStroke = Instance.new("UIStroke")
	modalStroke.Color = Color3.fromRGB(120, 160, 200)
	modalStroke.Transparency = 0.5
	modalStroke.Thickness = 1.5
	modalStroke.Parent = modalFrame

	-- Top Header Bar
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 38)
	header.BackgroundTransparency = 1
	header.Parent = modalFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = "Settings"
	titleLabel.Font = Enum.Font.FredokaOne
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
	titleLabel.Size = UDim2.new(1, -50, 1, 0)
	titleLabel.Position = UDim2.new(0, 16, 0, 0)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.SourceSansBold
	closeBtn.TextSize = 14
	closeBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
	closeBtn.Size = UDim2.new(0, 28, 0, 28)
	closeBtn.Position = UDim2.new(1, -34, 0, 5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	closeBtn.BackgroundTransparency = 0.4
	closeBtn.Parent = header

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		SettingsMenu.toggle()
	end)

	-- Left Side Tabs Container
	local leftSideFrame = Instance.new("Frame")
	leftSideFrame.Name = "SideTabs"
	leftSideFrame.Size = UDim2.new(0, 140, 1, -48)
	leftSideFrame.Position = UDim2.new(0, 10, 0, 42)
	leftSideFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
	leftSideFrame.BackgroundTransparency = 0.4
	leftSideFrame.BorderSizePixel = 0
	leftSideFrame.Parent = modalFrame

	local sideCorner = Instance.new("UICorner")
	sideCorner.CornerRadius = UDim.new(0, 8)
	sideCorner.Parent = leftSideFrame

	local sideLayout = Instance.new("UIListLayout")
	sideLayout.FillDirection = Enum.FillDirection.Vertical
	sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sideLayout.Padding = UDim.new(0, 6)
	sideLayout.Parent = leftSideFrame

	local sidePadding = Instance.new("UIPadding")
	sidePadding.PaddingTop = UDim.new(0, 6)
	sidePadding.Parent = leftSideFrame

	-- Right Content Area Container
	rightContentFrame = Instance.new("Frame")
	rightContentFrame.Name = "RightContent"
	rightContentFrame.Size = UDim2.new(1, -170, 1, -48)
	rightContentFrame.Position = UDim2.new(0, 160, 0, 42)
	rightContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	rightContentFrame.BackgroundTransparency = 0.3
	rightContentFrame.BorderSizePixel = 0
	rightContentFrame.Parent = modalFrame

	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, 8)
	contentCorner.Parent = rightContentFrame

	-- Create Side Tab Buttons
	for _, catData in ipairs(SideCategories) do
		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = "SideTab_" .. catData.ID
		tabBtn.Size = UDim2.new(1, -12, 0, 30)
		tabBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 46)
		tabBtn.BackgroundTransparency = 0.6
		tabBtn.Text = catData.Name
		tabBtn.Font = Enum.Font.SourceSansBold
		tabBtn.TextSize = 12
		tabBtn.TextColor3 = Color3.fromRGB(220, 225, 240)
		tabBtn.Parent = leftSideFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = tabBtn

		tabBtn.MouseButton1Click:Connect(function()
			activeSideCategory = catData.ID
			SettingsMenu.renderCategoryContent(catData.ID)
		end)
	end

	-- Render Initial Category
	SettingsMenu.renderCategoryContent("GameModes")

	-- Hotkey [F2] to toggle settings
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.F2 then
			SettingsMenu.toggle()
		end
	end)

	screenGui.Parent = playerGui
	print("[SettingsMenu] Loaded settings popup window!")
end

function SettingsMenu.toggle()
	isVisible = not isVisible
	if modalFrame then
		modalFrame.Visible = isVisible
	end
end

function SettingsMenu.renderCategoryContent(categoryId: string)
	if not rightContentFrame then return end

	-- Clear previous content
	for _, child in ipairs(rightContentFrame:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = rightContentFrame

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = rightContentFrame

	if categoryId == "GameModes" then
		-- Render Game Mode Selection
		for _, modeName in ipairs({ "Survival", "PvP", "Creative" }) do
			local modeRow = Instance.new("Frame")
			modeRow.Size = UDim2.new(1, 0, 0, 36)
			modeRow.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
			modeRow.BackgroundTransparency = 0.4
			modeRow.Parent = rightContentFrame

			local rCorner = Instance.new("UICorner")
			rCorner.CornerRadius = UDim.new(0, 6)
			rCorner.Parent = modeRow

			local modeLabel = Instance.new("TextLabel")
			modeLabel.Text = modeName .. " Mode"
			modeLabel.Font = Enum.Font.SourceSansBold
			modeLabel.TextSize = 13
			modeLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
			modeLabel.Size = UDim2.new(0.6, 0, 1, 0)
			modeLabel.Position = UDim2.new(0, 10, 0, 0)
			modeLabel.TextXAlignment = Enum.TextXAlignment.Left
			modeLabel.BackgroundTransparency = 1
			modeLabel.Parent = modeRow

			local selectBtn = Instance.new("TextButton")
			local currentActive = GameSettings.get("ActiveMode") == modeName
			selectBtn.Text = currentActive and "Active" or "Select"
			selectBtn.Font = Enum.Font.SourceSansBold
			selectBtn.TextSize = 11
			selectBtn.TextColor3 = currentActive and Color3.fromRGB(0, 255, 180) or Color3.fromRGB(200, 200, 220)
			selectBtn.Size = UDim2.new(0, 70, 0, 24)
			selectBtn.Position = UDim2.new(1, -78, 0, 6)
			selectBtn.BackgroundColor3 = currentActive and Color3.fromRGB(40, 80, 60) or Color3.fromRGB(40, 40, 55)
			selectBtn.Parent = modeRow

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 5)
			btnCorner.Parent = selectBtn

			selectBtn.MouseButton1Click:Connect(function()
				GameSettings.set("ActiveMode", modeName)
				if modeName == "Creative" then
					GameSettings.set("InfiniteResources", true)
				end
				SettingsMenu.renderCategoryContent("GameModes")
			end)
		end

	elseif categoryId == "DevCheats" then
		-- Render Developer Cheats Toggles
		local cheats = {
			{ Key = "InfiniteResources", Name = "Infinite Resources" },
			{ Key = "GodMode", Name = "God Mode" },
		}

		for _, cheat in ipairs(cheats) do
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 36)
			row.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
			row.BackgroundTransparency = 0.4
			row.Parent = rightContentFrame

			local rCorner = Instance.new("UICorner")
			rCorner.CornerRadius = UDim.new(0, 6)
			rCorner.Parent = row

			local label = Instance.new("TextLabel")
			label.Text = cheat.Name
			label.Font = Enum.Font.SourceSansBold
			label.TextSize = 13
			label.TextColor3 = Color3.fromRGB(240, 240, 255)
			label.Size = UDim2.new(0.6, 0, 1, 0)
			label.Position = UDim2.new(0, 10, 0, 0)
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.BackgroundTransparency = 1
			label.Parent = row

			local isON = GameSettings.get(cheat.Key) == true
			local toggleBtn = Instance.new("TextButton")
			toggleBtn.Text = isON and "ON" or "OFF"
			toggleBtn.Font = Enum.Font.SourceSansBold
			toggleBtn.TextSize = 11
			toggleBtn.TextColor3 = isON and Color3.fromRGB(0, 255, 180) or Color3.fromRGB(200, 200, 220)
			toggleBtn.Size = UDim2.new(0, 60, 0, 24)
			toggleBtn.Position = UDim2.new(1, -68, 0, 6)
			toggleBtn.BackgroundColor3 = isON and Color3.fromRGB(40, 90, 60) or Color3.fromRGB(50, 40, 40)
			toggleBtn.Parent = row

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 5)
			btnCorner.Parent = toggleBtn

			toggleBtn.MouseButton1Click:Connect(function()
				local newState = not GameSettings.get(cheat.Key)
				GameSettings.set(cheat.Key, newState)
				SettingsMenu.renderCategoryContent("DevCheats")
			end)
		end

	elseif categoryId == "GridSettings" then
		-- Render Grid Smoothness Toggle
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 36)
		row.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
		row.BackgroundTransparency = 0.4
		row.Parent = rightContentFrame

		local rCorner = Instance.new("UICorner")
		rCorner.CornerRadius = UDim.new(0, 6)
		rCorner.Parent = row

		local label = Instance.new("TextLabel")
		label.Text = "Smooth Grid Lerp"
		label.Font = Enum.Font.SourceSansBold
		label.TextSize = 13
		label.TextColor3 = Color3.fromRGB(240, 240, 255)
		label.Size = UDim2.new(0.6, 0, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.BackgroundTransparency = 1
		label.Parent = row

		local isON = GameSettings.get("SmoothGridSnapping") == true
		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Text = isON and "ON" or "OFF"
		toggleBtn.Font = Enum.Font.SourceSansBold
		toggleBtn.TextSize = 11
		toggleBtn.TextColor3 = isON and Color3.fromRGB(0, 255, 180) or Color3.fromRGB(200, 200, 220)
		toggleBtn.Size = UDim2.new(0, 60, 0, 24)
		toggleBtn.Position = UDim2.new(1, -68, 0, 6)
		toggleBtn.BackgroundColor3 = isON and Color3.fromRGB(40, 90, 60) or Color3.fromRGB(50, 40, 40)
		toggleBtn.Parent = row

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 5)
		btnCorner.Parent = toggleBtn

		toggleBtn.MouseButton1Click:Connect(function()
			local newState = not GameSettings.get("SmoothGridSnapping")
			GameSettings.set("SmoothGridSnapping", newState)
			SettingsMenu.renderCategoryContent("GridSettings")
		end)

	elseif categoryId == "AudioVisuals" then
		-- Render Audio Toggles
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 36)
		row.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
		row.BackgroundTransparency = 0.4
		row.Parent = rightContentFrame

		local rCorner = Instance.new("UICorner")
		rCorner.CornerRadius = UDim.new(0, 6)
		rCorner.Parent = row

		local label = Instance.new("TextLabel")
		label.Text = "Mewing SFX & Voice"
		label.Font = Enum.Font.SourceSansBold
		label.TextSize = 13
		label.TextColor3 = Color3.fromRGB(240, 240, 255)
		label.Size = UDim2.new(0.6, 0, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.BackgroundTransparency = 1
		label.Parent = row

		local isON = GameSettings.get("MewingSFX") == true
		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Text = isON and "ON" or "OFF"
		toggleBtn.Font = Enum.Font.SourceSansBold
		toggleBtn.TextSize = 11
		toggleBtn.TextColor3 = isON and Color3.fromRGB(0, 255, 180) or Color3.fromRGB(200, 200, 220)
		toggleBtn.Size = UDim2.new(0, 60, 0, 24)
		toggleBtn.Position = UDim2.new(1, -68, 0, 6)
		toggleBtn.BackgroundColor3 = isON and Color3.fromRGB(40, 90, 60) or Color3.fromRGB(50, 40, 40)
		toggleBtn.Parent = row

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 5)
		btnCorner.Parent = toggleBtn

		toggleBtn.MouseButton1Click:Connect(function()
			local newState = not GameSettings.get("MewingSFX")
			GameSettings.set("MewingSFX", newState)
			SettingsMenu.renderCategoryContent("AudioVisuals")
		end)
	end
end

return SettingsMenu
