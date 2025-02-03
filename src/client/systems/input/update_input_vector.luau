local components = require("@shared/components")
local world = require("@shared/world")
local frame = require("@shared/frame")
local controls = require("@client/controls")

local function bool_modifier(bool: boolean): number
	return if bool then 1 else 0
end

local function remove_nan(vec: vector): vector
	return vector.create(vec.X == vec.X and vec.X or 0, vec.Y == vec.Y and vec.Y or 0, vec.Z == vec.Z and vec.Z or 0)
end

return frame.on("input", function()
	local zAxis = bool_modifier(controls.BACKWARD.being_held) - bool_modifier(controls.FORWARD.being_held)
	local xAxis = bool_modifier(controls.RIGHT.being_held) - bool_modifier(controls.LEFT.being_held)

	local move_vector = vector.create(xAxis, 0, zAxis)
	local normalized_move_vector = remove_nan(vector.normalize(move_vector))

	for _, HumanoidInput in world:query(components.Input):iter() do
		HumanoidInput.move_vector = normalized_move_vector
	end
end)
