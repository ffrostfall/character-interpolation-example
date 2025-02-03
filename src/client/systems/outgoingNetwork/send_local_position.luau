local frame = require("@shared/frame")
local network = require("@net/client")
local world = require("@shared/world")
local components = require("@shared/components")

return frame.on("outgoing_net", function()
	for _, LocalHumanoid, Networked in world:query(components.LocalHumanoid, components.Networked):iter() do
		local position = LocalHumanoid.root.CFrame.Position
		local _, y_rot, _ = LocalHumanoid.root.CFrame:ToOrientation()

		network.send_local_position.fire({
			position = position,
			y_rot = y_rot,
		})
	end
end)
