--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))
local CraftingRecipes = require(Shared:WaitForChild("Modules"):WaitForChild("CraftingRecipes"))

local TopNavigationMenu = {}
local activeTab: string? = nil
local drawerFrame: Frame? = nil
local activeCategoryItemsFrame: Frame? = nil
local tooltipFrame: Frame? = nil
local tooltipTextLabel: TextLabel? = nil

-- Category Data Definitions
local Categories = {
	{
		ID = "Blocks",
		Name = "🧱 Blocks",
		Items = {
			-- Wood Series
			{ ID = "WoodCube1x1", Name = "Wood 1x1 Cube", Icon = "🪵" },
			{ ID = "WoodBeam1x2", Name = "Wood 1x2 Beam", Icon = "🪵" },
			{ ID = "WoodStairs", Name = "Wood Stairs", Icon = "🪜" },
			{ ID = "WoodHalfWall", Name = "Wood Half-Wall", Icon = "🪵" },
			-- Stone Series
			{ ID = "StoneCube1x1", Name = "Stone 1x1 Cube", Icon = "🪨" },
			{ ID = "StoneBeam1x2", Name = "Stone 1x2 Beam", Icon = "🪨" },
			{ ID = "StoneSlab2x2", Name = "Stone 2x2 Slab", Icon = "🪨" },
			{ ID = "StoneStairs", Name = "Stone Stairs", Icon = "📐" },
			-- Clay Series
			{ ID = "ClayBrick1x1", Name = "Clay Brick 1x1", Icon = "🧱" },
			{ ID = "ClayWall1x2", Name = "Clay Wall 1x2", Icon = "🧱" },
			-- Concrete Series
			{ ID = "ConcretePillar", Name = "Concrete Pillar", Icon = "🏗️" },
			{ ID = "ConcreteSlab", Name = "Concrete 2x2 Slab", Icon = "🏗️" },
			-- Special Series
			{ ID = "RizziteShield1x1", Name = "Rizzite Shield", Icon = "⚡" },
			{ ID = "SpikeTrap", Name = "Spike Trap", Icon = "⚙️" },
		},
	},
	{
		ID = "Buildings",
		Name = "🏰 Buildings",
		Items = {
			{ ID = "ArcherTower", Name = "Archer Post", Icon = "🏹" },
			{ ID = "StorageCore", Name = "Storage Chest", Icon = "📦" },
			{ ID = "SiegeWorkshop", Name = "Catapult Workshop", Icon = "⚒️" },
			{ ID = "CastleGate", Name = "Iron Portcullis", Icon = "🚪" },
		},
	},
	{
		ID = "Clothes",
		Name = "👕 Skins",
		Items = {
			{ ID = "Gigachad", Name = "Gigachad Outfit", Icon = "🗿" },
			{ ID = "KaiCenat", Name = "Rizz Streamer Drip", Icon = "👑" },
			{ ID = "GrimaceShake", Name = "Purple Grimace", Icon = "🥤" },
			{ ID = "GoldenSigma", Name = "Pure Gold Armor", Icon = "✨" },
		},
	},
	{
		ID = "Weapons",
		Name = "⚔️ Weapons",
		Items = {
			{ ID = "RizzSword", Name = "Rizz Blade", Icon = "🗡️" },
			{ ID = "FanumBow", Name = "Fanum Tax Bow", Icon = "🏹" },
			{ ID = "OhioAxe", Name = "Ohio Battleaxe", Icon = "🪓" },
			{ ID = "SkibidiBomb", Name = "Kamikaze Bomb", Icon = "💣" },
		},
	},
	{
		ID = "Tasks",
		Name = "📜 Tasks",
		Items = {
			{ ID = "ChopWood", Name = "Harvest Ohio Wood", Icon = "🪓" },
			{ ID = "MineStone", Name = "Mine Gyatt Granite", Icon = "⛏️" },
			{ ID = "BuildWall", Name = "Auto-Build Castle", Icon = "🧱" },
			{ ID = "GuardBase", Name = "Patrol Perimeter", Icon = "🛡️" },
		},
	},
	{
		ID = "Shop",
		Name = "🛒 Shop",
		Items = {
			{ ID = "Blueprints", Name = "Blueprint Slots", Icon = "📜" },
			{ ID = "UITheme", Name = "Neon HUD Theme", Icon = "🎨" },
			{ ID = "Soundboard", Name = "Mewing SFX Pack", Icon = "🔊" },
			{ ID = "PetFollower", Name = "Mini Sigma Pet", Icon = "🐾" },
		},
	},
}

function TopNavigationMenu.init()
	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then
		LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait() :: any
	end
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10) :: PlayerGui?
	if not playerGui then
		warn("[TopNavigationMenu] PlayerGui not found!")
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TopNavigationGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 100
	screenGui.IgnoreGuiInset = true

	-- Top Bar Container (Centered at top)
	local topBar = Instance.new("Frame")
	topBar.Name = "TopNavFrame"
	topBar.Size = UDim2.new(0, 680, 0, 48)
	topBar.Position = UDim2.new(0.5, -340, 0, 40)
	topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
	topBar.BackgroundTransparency = 0.35
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
	drawerFrame.Size = UDim2.new(0, 680, 0, 0)
	drawerFrame.Position = UDim2.new(0.5, -340, 0, 95)
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

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "DrawerScrollingFrame"
	scrollingFrame.Size = UDim2.new(1, -16, 1, -16)
	scrollingFrame.Position = UDim2.new(0, 8, 0, 8)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
	scrollingFrame.Parent = drawerFrame

	activeCategoryItemsFrame = Instance.new("Frame")
	activeCategoryItemsFrame.Name = "ItemsContainer"
	activeCategoryItemsFrame.Size = UDim2.new(1, 0, 1, 0)
	activeCategoryItemsFrame.BackgroundTransparency = 1
	activeCategoryItemsFrame.Parent = scrollingFrame

	local drawerLayout = Instance.new("UIListLayout")
	drawerLayout.FillDirection = Enum.FillDirection.Horizontal
	drawerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	drawerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	drawerLayout.Padding = UDim.new(0, 8)
	drawerLayout.Parent = activeCategoryItemsFrame

	-- Floating Hover Crafting Recipe Tooltip Tab
	tooltipFrame = Instance.new("Frame")
	tooltipFrame.Name = "CraftingRecipeTooltip"
	tooltipFrame.Size = UDim2.new(0, 220, 0, 36)
	tooltipFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
	tooltipFrame.BackgroundTransparency = 0.15
	tooltipFrame.BorderSizePixel = 0
	tooltipFrame.Visible = false
	tooltipFrame.ZIndex = 200
	tooltipFrame.Parent = screenGui

	local tooltipCorner = Instance.new("UICorner")
	tooltipCorner.CornerRadius = UDim.new(0, 6)
	tooltipCorner.Parent = tooltipFrame

	local tooltipStroke = Instance.new("UIStroke")
	tooltipStroke.Color = Color3.fromRGB(0, 220, 255)
	tooltipStroke.Transparency = 0.3
	tooltipStroke.Thickness = 1.2
	tooltipStroke.Parent = tooltipFrame

	tooltipTextLabel = Instance.new("TextLabel")
	tooltipTextLabel.Name = "RecipeLabel"
	tooltipTextLabel.Size = UDim2.new(1, -12, 1, 0)
	tooltipTextLabel.Position = UDim2.new(0, 6, 0, 0)
	tooltipTextLabel.Font = Enum.Font.SourceSansBold
	tooltipTextLabel.TextSize = 13
	tooltipTextLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
	tooltipTextLabel.TextXAlignment = Enum.TextXAlignment.Center
	tooltipTextLabel.TextWrapped = true
	tooltipTextLabel.BackgroundTransparency = 1
	tooltipTextLabel.ZIndex = 201
	tooltipTextLabel.Parent = tooltipFrame

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

	screenGui.Parent = playerGui
	print("[TopNavigationMenu] Loaded top glassmorphic menu bar with recipe tooltips!")
end

function TopNavigationMenu.selectTab(categoryData: any)
	if activeTab == categoryData.ID then
		-- Toggle close drawer
		activeTab = nil
		if tooltipFrame then tooltipFrame.Visible = false end
		TweenService:Create(drawerFrame :: Frame, TweenInfo.new(0.2), { Size = UDim2.new(0, 680, 0, 0) }):Play()
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
		card.Size = UDim2.new(0, 135, 0, 65)
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
		iconLabel.Size = UDim2.new(1, 0, 0, 26)
		iconLabel.Position = UDim2.new(0, 0, 0, 4)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Parent = card

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Text = item.Name
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.TextSize = 11
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Size = UDim2.new(1, -6, 0, 18)
		nameLabel.Position = UDim2.new(0, 3, 0, 28)
		nameLabel.TextWrapped = true
		nameLabel.BackgroundTransparency = 1
		nameLabel.Parent = card

		-- Display formatted crafting recipe requirement string
		local formattedRecipe = CraftingRecipes.getFormattedRecipe(item.ID)
		local detailLabel = Instance.new("TextLabel")
		detailLabel.Text = formattedRecipe
		detailLabel.Font = Enum.Font.SourceSansItalic
		detailLabel.TextSize = 9
		detailLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
		detailLabel.Size = UDim2.new(1, -6, 0, 14)
		detailLabel.Position = UDim2.new(0, 3, 0, 48)
		detailLabel.TextTruncate = Enum.TextTruncate.AtEnd
		detailLabel.BackgroundTransparency = 1
		detailLabel.Parent = card

		-- HOVER EVENT: Show Crafting Recipe Tooltip Tab formatted as resourcename_x(amount)
		card.MouseEnter:Connect(function()
			if tooltipFrame and tooltipTextLabel then
				tooltipTextLabel.Text = "🛠️ Recipe: " .. formattedRecipe
				tooltipFrame.Position = UDim2.new(0, card.AbsolutePosition.X - 10, 0, card.AbsolutePosition.Y + card.AbsoluteSize.Y + 8)
				tooltipFrame.Visible = true
			end
		end)

		card.MouseLeave:Connect(function()
			if tooltipFrame then
				tooltipFrame.Visible = false
			end
		end)

		card.MouseButton1Click:Connect(function()
			print(string.format("[TopNavigationMenu] Selected item: %s (%s)", item.Name, categoryData.ID))
			if categoryData.ID == "Blocks" then
				local PlacementController = require(script.Parent.Parent:WaitForChild("Controllers"):WaitForChild("PlacementController"))
				PlacementController.setSelectedBlock(item.ID)
				if not PlacementController.isPlacementActiveMode() then
					PlacementController.togglePlacementMode()
				end
			end
		end)
	end

	-- Expand drawer panel
	TweenService:Create(drawerFrame :: Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 680, 0, 85) }):Play()
end

return TopNavigationMenu
