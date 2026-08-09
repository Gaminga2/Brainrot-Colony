--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Modules"):WaitForChild("GameConfig"))
local CraftingRecipes = require(Shared:WaitForChild("Modules"):WaitForChild("CraftingRecipes"))

local TopNavigationMenu = {}
local activeTab: string? = nil
local drawerFrame: Frame? = nil
local activeCategoryItemsFrame: Frame? = nil
local tooltipFrame: Frame? = nil
local tooltipTextLabel: TextLabel? = nil

-- Category Data Definitions (Words only, no emojis, clean & minimal)
local Categories = {
	{
		ID = "Blocks",
		Name = "Blocks",
			-- Environmental & Terrain Series
			{ ID = "GrassTopBlock1x1", Name = "Grass Top Block" },
			{ ID = "CobblestoneBlock1x1", Name = "Cobblestone 1x1" },
			{ ID = "MossyStoneBlock1x1", Name = "Mossy Stone 1x1" },
			{ ID = "SandstoneBlock1x1", Name = "Sandstone 1x1" },
			-- Wood Series
			{ ID = "WoodCube1x1", Name = "Wood 1x1 Cube" },
			{ ID = "WoodBeam1x2", Name = "Wood 1x2 Beam" },
			{ ID = "WoodStairs", Name = "Wood Stairs" },
			{ ID = "WoodHalfWall", Name = "Wood Half-Wall" },
			-- Stone Series
			{ ID = "StoneCube1x1", Name = "Stone 1x1 Cube" },
			{ ID = "StoneBeam1x2", Name = "Stone 1x2 Beam" },
			{ ID = "StoneSlab2x2", Name = "Stone 2x2 Slab" },
			{ ID = "StoneStairs", Name = "Stone Stairs" },
			-- Clay Series
			{ ID = "ClayBrick1x1", Name = "Clay Brick 1x1" },
			{ ID = "ClayWall1x2", Name = "Clay Wall 1x2" },
			-- Concrete Series
			{ ID = "ConcretePillar", Name = "Concrete Pillar" },
			{ ID = "ConcreteSlab", Name = "Concrete 2x2 Slab" },
			-- Special Series
			{ ID = "RizziteShield1x1", Name = "Rizzite Shield" },
			{ ID = "SpikeTrap", Name = "Spike Trap" },
		},
	},
	{
		ID = "Buildings",
		Name = "Buildings",
		Items = {
			{ ID = "ArcherTower", Name = "Archer Post" },
			{ ID = "StorageCore", Name = "Storage Chest" },
			{ ID = "SiegeWorkshop", Name = "Catapult Workshop" },
			{ ID = "CastleGate", Name = "Iron Portcullis" },
		},
	},
	{
		ID = "Clothes",
		Name = "Skins",
		Items = {
			{ ID = "Gigachad", Name = "Gigachad Outfit" },
			{ ID = "KaiCenat", Name = "Rizz Streamer Drip" },
			{ ID = "GrimaceShake", Name = "Purple Grimace" },
			{ ID = "GoldenSigma", Name = "Pure Gold Armor" },
		},
	},
	{
		ID = "Weapons",
		Name = "Weapons",
		Items = {
			{ ID = "RizzSword", Name = "Rizz Blade" },
			{ ID = "FanumBow", Name = "Fanum Tax Bow" },
			{ ID = "OhioAxe", Name = "Ohio Battleaxe" },
			{ ID = "SkibidiBomb", Name = "Kamikaze Bomb" },
		},
	},
	{
		ID = "Tasks",
		Name = "Tasks",
		Items = {
			{ ID = "ChopWood", Name = "Harvest Ohio Wood" },
			{ ID = "MineStone", Name = "Mine Gyatt Granite" },
			{ ID = "BuildWall", Name = "Auto-Build Castle" },
			{ ID = "GuardBase", Name = "Patrol Perimeter" },
		},
	},
	{
		ID = "Shop",
		Name = "Shop",
		Items = {
			{ ID = "Blueprints", Name = "Blueprint Slots" },
			{ ID = "UITheme", Name = "Neon HUD Theme" },
			{ ID = "Soundboard", Name = "Mewing SFX Pack" },
			{ ID = "PetFollower", Name = "Mini Sigma Pet" },
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

	-- Minimal Slim Top Bar Container (Centered, 480px wide x 34px high)
	local topBar = Instance.new("Frame")
	topBar.Name = "TopNavFrame"
	topBar.Size = UDim2.new(0, 480, 0, 34)
	topBar.Position = UDim2.new(0.5, -240, 0, 25)
	topBar.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
	topBar.BackgroundTransparency = 0.45 -- Soft subtle transparency
	topBar.BorderSizePixel = 0
	topBar.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = topBar

	-- Soft subtle outline stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(120, 160, 200)
	stroke.Transparency = 0.6
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = topBar

	-- Minimal Horizontal List layout for top tabs
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = topBar

	-- Collapsible Soft Drawer Panel below top bar
	drawerFrame = Instance.new("Frame")
	drawerFrame.Name = "CategoryDrawer"
	drawerFrame.Size = UDim2.new(0, 480, 0, 0)
	drawerFrame.Position = UDim2.new(0.5, -240, 0, 64)
	drawerFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
	drawerFrame.BackgroundTransparency = 0.4
	drawerFrame.ClipsDescendants = true
	drawerFrame.BorderSizePixel = 0
	drawerFrame.Parent = screenGui

	local drawerCorner = Instance.new("UICorner")
	drawerCorner.CornerRadius = UDim.new(0, 8)
	drawerCorner.Parent = drawerFrame

	local drawerStroke = Instance.new("UIStroke")
	drawerStroke.Color = Color3.fromRGB(100, 130, 170)
	drawerStroke.Transparency = 0.7
	drawerStroke.Thickness = 1
	drawerStroke.Parent = drawerFrame

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "DrawerScrollingFrame"
	scrollingFrame.Size = UDim2.new(1, -12, 1, -12)
	scrollingFrame.Position = UDim2.new(0, 6, 0, 6)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.ScrollBarThickness = 4
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 160, 200)
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
	drawerLayout.Padding = UDim.new(0, 6)
	drawerLayout.Parent = activeCategoryItemsFrame

	-- Floating Minimal Recipe Tooltip Tab
	tooltipFrame = Instance.new("Frame")
	tooltipFrame.Name = "CraftingRecipeTooltip"
	tooltipFrame.Size = UDim2.new(0, 180, 0, 24)
	tooltipFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
	tooltipFrame.BackgroundTransparency = 0.2
	tooltipFrame.BorderSizePixel = 0
	tooltipFrame.Visible = false
	tooltipFrame.ZIndex = 200
	tooltipFrame.Parent = screenGui

	local tooltipCorner = Instance.new("UICorner")
	tooltipCorner.CornerRadius = UDim.new(0, 6)
	tooltipCorner.Parent = tooltipFrame

	local tooltipStroke = Instance.new("UIStroke")
	tooltipStroke.Color = Color3.fromRGB(120, 180, 240)
	tooltipStroke.Transparency = 0.5
	tooltipStroke.Thickness = 1
	tooltipStroke.Parent = tooltipFrame

	tooltipTextLabel = Instance.new("TextLabel")
	tooltipTextLabel.Name = "RecipeLabel"
	tooltipTextLabel.Size = UDim2.new(1, -8, 1, 0)
	tooltipTextLabel.Position = UDim2.new(0, 4, 0, 0)
	tooltipTextLabel.Font = Enum.Font.SourceSansBold
	tooltipTextLabel.TextSize = 11
	tooltipTextLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
	tooltipTextLabel.TextXAlignment = Enum.TextXAlignment.Center
	tooltipTextLabel.TextWrapped = true
	tooltipTextLabel.BackgroundTransparency = 1
	tooltipTextLabel.ZIndex = 201
	tooltipTextLabel.Parent = tooltipFrame

	-- Create Minimal Top Bar Category Buttons (Words only, compact width)
	for _, catData in ipairs(Categories) do
		local btn = Instance.new("TextButton")
		btn.Name = "Tab_" .. catData.ID
		btn.Size = UDim2.new(0, 74, 0, 24)
		btn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
		btn.BackgroundTransparency = 0.5
		btn.Text = catData.Name
		btn.Font = Enum.Font.SourceSansBold
		btn.TextSize = 12
		btn.TextColor3 = Color3.fromRGB(220, 225, 240)
		btn.AutoButtonColor = true
		btn.Parent = topBar

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 5)
		btnCorner.Parent = btn

		local btnStroke = Instance.new("UIStroke")
		btnStroke.Color = Color3.fromRGB(80, 80, 110)
		btnStroke.Transparency = 0.6
		btnStroke.Thickness = 1
		btnStroke.Parent = btn

		-- Hover effects
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.25 }):Play()
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
	print("[TopNavigationMenu] Loaded minimal soft top menu bar (no emojis)!")
end

function TopNavigationMenu.selectTab(categoryData: any)
	if activeTab == categoryData.ID then
		-- Toggle close drawer
		activeTab = nil
		if tooltipFrame then tooltipFrame.Visible = false end
		TweenService:Create(drawerFrame :: Frame, TweenInfo.new(0.2), { Size = UDim2.new(0, 480, 0, 0) }):Play()
		return
	end

	activeTab = categoryData.ID

	-- Clear old items
	for _, child in ipairs(activeCategoryItemsFrame:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	-- Populate sub-drawer compact item cards (Words only, 105px wide x 38px high)
	for _, item in ipairs(categoryData.Items) do
		local card = Instance.new("TextButton")
		card.Name = "Item_" .. item.ID
		card.Size = UDim2.new(0, 105, 0, 38)
		card.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
		card.BackgroundTransparency = 0.3
		card.Text = ""
		card.Parent = activeCategoryItemsFrame

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 5)
		cardCorner.Parent = card

		local cardStroke = Instance.new("UIStroke")
		cardStroke.Color = Color3.fromRGB(120, 160, 200)
		cardStroke.Transparency = 0.75
		cardStroke.Thickness = 1
		cardStroke.Parent = card

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Text = item.Name
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.TextSize = 11
		nameLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
		nameLabel.Size = UDim2.new(1, -6, 0, 16)
		nameLabel.Position = UDim2.new(0, 3, 0, 4)
		nameLabel.TextWrapped = true
		nameLabel.BackgroundTransparency = 1
		nameLabel.Parent = card

		-- Display formatted crafting recipe requirement string
		local formattedRecipe = CraftingRecipes.getFormattedRecipe(item.ID)
		local detailLabel = Instance.new("TextLabel")
		detailLabel.Text = formattedRecipe
		detailLabel.Font = Enum.Font.SourceSansItalic
		detailLabel.TextSize = 9
		detailLabel.TextColor3 = Color3.fromRGB(130, 200, 240)
		detailLabel.Size = UDim2.new(1, -6, 0, 14)
		detailLabel.Position = UDim2.new(0, 3, 0, 20)
		detailLabel.TextTruncate = Enum.TextTruncate.AtEnd
		detailLabel.BackgroundTransparency = 1
		detailLabel.Parent = card

		-- HOVER EVENT: Show Minimal Crafting Recipe Tooltip Tab
		card.MouseEnter:Connect(function()
			if tooltipFrame and tooltipTextLabel then
				tooltipTextLabel.Text = "Recipe: " .. formattedRecipe
				tooltipFrame.Position = UDim2.new(0, card.AbsolutePosition.X - 5, 0, card.AbsolutePosition.Y + card.AbsoluteSize.Y + 6)
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

	-- Expand compact drawer panel
	TweenService:Create(drawerFrame :: Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 480, 0, 52) }):Play()
end

return TopNavigationMenu
