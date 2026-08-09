--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))

local TopNavigationMenu = {}
local activeTab: string? = nil
local drawerFrame: Frame? = nil
local activeCategoryItemsFrame: Frame? = nil

-- Category Data Definitions
local Categories = {
	{
		ID = "Blocks",
		Name = "🧱 Blocks",
		Items = {
			{ ID = "WoodWall", Name = "Wood Block", Icon = "🪵", Cost = "2 Ohio Wood" },
			{ ID = "StoneWall", Name = "Stone Block", Icon = "🪨", Cost = "3 Gyatt Granite" },
			{ ID = "RizziteReinforcedWall", Name = "Rizzite Shield", Icon = "⚡", Cost = "4 Granite + 2 Rizzite" },
			{ ID = "SpikeTrap", Name = "Spike Trap", Icon = "⚙️", Cost = "1 Wood + 2 Granite" },
		},
	},
	{
		ID = "Buildings",
		Name = "🏰 Buildings",
		Items = {
			{ ID = "ArcherTower", Name = "Archer Post", Icon = "🏹", Cost = "15 Wood + 10 Granite" },
			{ ID = "StorageCore", Name = "Storage Chest", Icon = "📦", Cost = "20 Wood" },
			{ ID = "SiegeWorkshop", Name = "Catapult Workshop", Icon = "⚒️", Cost = "30 Granite + 10 Rizzite" },
			{ ID = "CastleGate", Name = "Iron Portcullis", Icon = "🚪", Cost = "25 Granite" },
		},
	},
	{
		ID = "Clothes",
		Name = "👕 Skins",
		Items = {
			{ ID = "Gigachad", Name = "Gigachad Outfit", Icon = "🗿", Type = "Skin" },
			{ ID = "KaiCenat", Name = "Rizz Streamer Drip", Icon = "👑", Type = "Skin" },
			{ ID = "GrimaceShake", Name = "Purple Grimace", Icon = "🥤", Type = "Skin" },
			{ ID = "GoldenSigma", Name = "Pure Gold Armor", Icon = "✨", Type = "Skin" },
		},
	},
	{
		ID = "Weapons",
		Name = "⚔️ Weapons",
		Items = {
			{ ID = "RizzSword", Name = "Rizz Blade", Icon = "🗡️", Dmg = "35 Dmg" },
			{ ID = "FanumBow", Name = "Fanum Tax Bow", Icon = "🏹", Dmg = "25 Dmg" },
			{ ID = "OhioAxe", Name = "Ohio Battleaxe", Icon = "🪓", Dmg = "50 Dmg" },
			{ ID = "SkibidiBomb", Name = "Kamikaze Bomb", Icon = "💣", Dmg = "200 Dmg" },
		},
	},
	{
		ID = "Tasks",
		Name = "📜 Tasks",
		Items = {
			{ ID = "ChopWood", Name = "Harvest Ohio Wood", Icon = "🪓", Target = "Trees" },
			{ ID = "MineStone", Name = "Mine Gyatt Granite", Icon = "⛏️", Target = "Rocks" },
			{ ID = "BuildWall", Name = "Auto-Build Castle", Icon = "🧱", Target = "Grid" },
			{ ID = "GuardBase", Name = "Patrol Perimeter", Icon = "🛡️", Target = "Core" },
		},
	},
	{
		ID = "Shop",
		Name = "🛒 Shop",
		Items = {
			{ ID = "Blueprints", Name = "Blueprint Slots", Icon = "📜", Drip = "QoL" },
			{ ID = "UITheme", Name = "Neon HUD Theme", Icon = "🎨", Drip = "Cosmetic" },
			{ ID = "Soundboard", Name = "Mewing SFX Pack", Icon = "🔊", Drip = "Audio" },
			{ ID = "PetFollower", Name = "Mini Sigma Pet", Icon = "🐾", Drip = "Pet" },
		},
	},
}

function TopNavigationMenu.init()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TopNavigationGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 10

	-- Top Bar Container (Centered at top)
	local topBar = Instance.new("Frame")
	topBar.Name = "TopNavFrame"
	topBar.Size = UDim2.new(0, 680, 0, 48)
	topBar.Position = UDim2.new(0.5, -340, 0, 15)
	topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
	topBar.BackgroundTransparency = 0.35 -- Semi-transparent glass background
	topBar.BorderSizePixel = 0
	topBar.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = topBar

	-- Subtle outline stroke to stand out
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 200, 255)
	stroke.Transparency = 0.45
	stroke.Thickness = 1.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = topBar

	-- Grid/List layout for top tabs
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Padding = UDim.new(0, 6)
	listLayout.Parent = topBar

	-- Collapsible Drawer Panel below top bar
	drawerFrame = Instance.new("Frame")
	drawerFrame.Name = "CategoryDrawer"
	drawerFrame.Size = UDim2.new(0, 640, 0, 0)
	drawerFrame.Position = UDim2.new(0.5, -320, 0, 70)
	drawerFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
	drawerFrame.BackgroundTransparency = 0.3
	drawerFrame.ClipsDescendants = true
	drawerFrame.BorderSizePixel = 0
	drawerFrame.Parent = screenGui

	local drawerCorner = Instance.new("UICorner")
	drawerCorner.CornerRadius = UDim.new(0, 8)
	drawerCorner.Parent = drawerFrame

	local drawerStroke = Instance.new("UIStroke")
	drawerStroke.Color = Color3.fromRGB(100, 100, 130)
	drawerStroke.Transparency = 0.6
	drawerStroke.Thickness = 1
	drawerStroke.Parent = drawerFrame

	activeCategoryItemsFrame = Instance.new("Frame")
	activeCategoryItemsFrame.Name = "ItemsContainer"
	activeCategoryItemsFrame.Size = UDim2.new(1, -20, 1, -20)
	activeCategoryItemsFrame.Position = UDim2.new(0, 10, 0, 10)
	activeCategoryItemsFrame.BackgroundTransparency = 1
	activeCategoryItemsFrame.Parent = drawerFrame

	local drawerLayout = Instance.new("UIListLayout")
	drawerLayout.FillDirection = Enum.FillDirection.Horizontal
	drawerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	drawerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	drawerLayout.Padding = UDim.new(0, 10)
	drawerLayout.Parent = activeCategoryItemsFrame

	-- Create Top Bar Category Buttons
	for _, catData in ipairs(Categories) do
		local btn = Instance.new("TextButton")
		btn.Name = "Tab_" .. catData.ID
		btn.Size = UDim2.new(0, 105, 0, 36)
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
		btn.BackgroundTransparency = 0.5
		btn.Text = catData.Name
		btn.Font = Enum.Font.FredokaOne
		btn.TextSize = 14
		btn.TextColor3 = Color3.fromRGB(240, 240, 250)
		btn.AutoButtonColor = true
		btn.Parent = topBar

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = btn

		local btnStroke = Instance.new("UIStroke")
		btnStroke.Color = Color3.fromRGB(70, 70, 95)
		btnStroke.Transparency = 0.5
		btnStroke.Thickness = 1
		btnStroke.Parent = btn

		-- Hover effects
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.2 }):Play()
		end)
		btn.MouseLeave:Connect(function()
			if activeTab ~= catData.ID then
				TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.5 }):Play()
			end
		end)

		-- Tab Click Handler
		btn.MouseButton1Click:Connect(function()
			TopNavigationMenu.selectTab(catData)
		end)
	end

	screenGui.Parent = PlayerGui
	print("[TopNavigationMenu] Loaded top glassmorphic menu bar!")
end

function TopNavigationMenu.selectTab(categoryData: any)
	if activeTab == categoryData.ID then
		-- Toggle close drawer
		activeTab = nil
		TweenService:Create(drawerFrame :: Frame, TweenInfo.new(0.2), { Size = UDim2.new(0, 640, 0, 0) }):Play()
		return
	end

	activeTab = categoryData.ID

	-- Clear old items
	for _, child in ipairs(activeCategoryItemsFrame:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	-- Populate sub-drawer items
	for _, item in ipairs(categoryData.Items) do
		local card = Instance.new("TextButton")
		card.Name = "Item_" .. item.ID
		card.Size = UDim2.new(0, 140, 0, 65)
		card.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
		card.BackgroundTransparency = 0.2
		card.Text = ""
		card.Parent = activeCategoryItemsFrame

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 6)
		cardCorner.Parent = card

		local cardStroke = Instance.new("UIStroke")
		cardStroke.Color = Color3.fromRGB(0, 200, 255)
		cardStroke.Transparency = 0.7
		cardStroke.Thickness = 1
		cardStroke.Parent = card

		local iconLabel = Instance.new("TextLabel")
		iconLabel.Text = item.Icon or "✨"
		iconLabel.TextSize = 22
		iconLabel.Size = UDim2.new(1, 0, 0, 28)
		iconLabel.Position = UDim2.new(0, 0, 0, 4)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Parent = card

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Text = item.Name
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.TextSize = 12
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Size = UDim2.new(1, 0, 0, 20)
		nameLabel.Position = UDim2.new(0, 0, 0, 32)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Parent = card

		local detailText = item.Cost or item.Dmg or item.Drip or item.Target or ""
		local detailLabel = Instance.new("TextLabel")
		detailLabel.Text = detailText
		detailLabel.Font = Enum.Font.SourceSansItalic
		detailLabel.TextSize = 10
		detailLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
		detailLabel.Size = UDim2.new(1, 0, 0, 14)
		detailLabel.Position = UDim2.new(0, 0, 0, 48)
		detailLabel.BackgroundTransparency = 1
		detailLabel.Parent = card

		card.MouseButton1Click:Connect(function()
			print(string.format("[TopNavigationMenu] Selected item: %s (%s)", item.Name, categoryData.ID))
			if categoryData.ID == "Blocks" then
				local PlacementController = require(script.Parent.Parent.Controllers.PlacementController)
				PlacementController.setSelectedBlock(item.ID)
				if not PlacementController.isPlacementActiveMode() then
					PlacementController.togglePlacementMode()
				end
			end
		end)
	end

	-- Expand drawer panel
	TweenService:Create(drawerFrame :: Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 640, 0, 85) }):Play()
end

return TopNavigationMenu
