--!strict
local GameConfig = require(script.Parent.GameConfig)

local GridUtil = {}
local GRID_SIZE = GameConfig.GRID_SIZE

-- Snap a world position to the nearest grid coordinate
function GridUtil.snapToGrid(pos: Vector3): Vector3
	local x = math.floor((pos.X + GRID_SIZE / 2) / GRID_SIZE) * GRID_SIZE
	local y = math.floor((pos.Y + GRID_SIZE / 2) / GRID_SIZE) * GRID_SIZE
	local z = math.floor((pos.Z + GRID_SIZE / 2) / GRID_SIZE) * GRID_SIZE
	return Vector3.new(x, y, z)
end

-- Convert grid position to unique string key "X_Y_Z"
function GridUtil.toGridKey(pos: Vector3): string
	local snapped = GridUtil.snapToGrid(pos)
	return string.format("%d_%d_%d", snapped.X, snapped.Y, snapped.Z)
end

-- Parse grid key back to Vector3
function GridUtil.fromGridKey(key: string): Vector3?
	local x, y, z = key:match("^(-?%d+)_(-?%d+)_(-?%d+)$")
	if x and y and z then
		return Vector3.new(tonumber(x), tonumber(y), tonumber(z))
	end
	return nil
end

return GridUtil
