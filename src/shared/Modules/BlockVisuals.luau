--!strict
local BlockVisuals = {}

-- Cute Derpy Brainrot Face Texture Asset IDs (Classic cute faces, blush cheeks, cat eyes)
BlockVisuals.CuteFaces = {
	DerpyBlush = "rbxassetid://7074786", -- Cute derpy face
	OwOFace = "rbxassetid://7074749",    -- Cute OwO face
	HappySmile = "rbxassetid://7074709", -- Cute happy smile
	UwUFace = "rbxassetid://1215730303", -- Cute UwU face
}

-- Apply Soft Bevels, Cute Pastel Colors, and Derpy Decals to a Block
function BlockVisuals.applyCuteStyling(part: BasePart, blockType: string)
	part.CastShadow = true

	-- Create Soft Bevel Mesh for pillowy soft block edges
	local mesh = part:FindFirstChildOfClass("SpecialMesh") :: SpecialMesh?
	if not mesh and part:IsA("Part") then
		mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Brick
		mesh.Scale = Vector3.new(0.98, 0.98, 0.98) -- Slightly inset for soft rounded edges
		mesh.Parent = part
	end

	-- Special Multi-Face Texturing for GrassTopBlock1x1
	if blockType == "GrassTopBlock1x1" then
		part.Color = Color3.fromRGB(135, 90, 50) -- Dirt side color
		part.Material = Enum.Material.Ground
		if not part:FindFirstChild("TopGrassTexture") then
			local topTex = Instance.new("Texture")
			topTex.Name = "TopGrassTexture"
			topTex.Face = Enum.NormalId.Top
			topTex.Texture = "rbxassetid://6372755" -- Smooth Grass top texture
			topTex.Color3 = Color3.fromRGB(100, 185, 75)
			topTex.StudsPerTileU = 2
			topTex.StudsPerTileV = 2
			topTex.Parent = part
		end
	end

	-- Add Cute Derpy Face Decal on Front Face (20% chance for extra cute brainrot flavor!)
	if math.random() < 0.35 and not part:FindFirstChild("CuteFaceDecal") then
		local faceDecal = Instance.new("Decal")
		faceDecal.Name = "CuteFaceDecal"
		faceDecal.Face = Enum.NormalId.Front
		
		local faceList = {
			BlockVisuals.CuteFaces.DerpyBlush,
			BlockVisuals.CuteFaces.OwOFace,
			BlockVisuals.CuteFaces.HappySmile,
			BlockVisuals.CuteFaces.UwUFace,
		}
		faceDecal.Texture = faceList[math.random(1, #faceList)]
		faceDecal.Transparency = 0.15
		faceDecal.Parent = part
	end
end

return BlockVisuals
