local WALKSPEED = 16

local frame = require("@shared/frame")
local components = require("@shared/components")
local world = require("@shared/world")

return frame.on("physics", function()
	for _, LocalHumanoid, HumanoidInput in world:query(components.LocalHumanoid, components.HumanoidInput):iter() do
		LocalHumanoid.movement.VectorVelocity = LocalHumanoid.root.CFrame:VectorToWorldSpace(HumanoidInput.move_vector)
			* WALKSPEED
	end
end)
