local components = require("@shared/components")
local world = require("@shared/world")
local frame = require("@shared/frame")
local controls = require("@client/controls")

local function boolModifier(bool: boolean): number
	return if bool then 1 else 0
end

local function removeNaN(vec: vector): vector
	return Vector3.new(vec.X == vec.X and vec.X or 0, vec.Y == vec.Y and vec.Y or 0, vec.Z == vec.Z and vec.Z or 0)
end

return frame.on("input", function()
	local zAxis = boolModifier(controls.BACKWARD.beingHeld) - boolModifier(controls.FORWARD.beingHeld)
	local xAxis = boolModifier(controls.RIGHT.beingHeld) - boolModifier(controls.LEFT.beingHeld)

	local moveVector = vector.create(xAxis, 0, zAxis)
	local normalizedMoveVector = removeNaN(vector.normalize(moveVector))

	for _, HumanoidInput in world:query(components.HumanoidInput):iter() do
		HumanoidInput.moveVector = normalizedMoveVector
	end
end)
