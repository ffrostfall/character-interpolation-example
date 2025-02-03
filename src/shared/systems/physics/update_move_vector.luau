local WALKSPEED = 16

local frame = require("@shared/frame")
local components = require("@shared/components")
local world = require("@shared/world")

return frame.on("physics", function()
	for _, LocalHumanoid, HumanoidInput in world:query(components.SimulatedRig, components.Input):iter() do
		local world_move_vector = LocalHumanoid.root.CFrame:VectorToWorldSpace(HumanoidInput.move_vector)

		LocalHumanoid.movement.VectorVelocity = world_move_vector * WALKSPEED
	end
end)
