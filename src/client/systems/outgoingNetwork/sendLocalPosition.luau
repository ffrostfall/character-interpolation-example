local frame = require("@shared/frame")
local network = require("@network/client")
local world = require("@shared/world")
local components = require("@shared/components")

return frame.on("outgoingNetwork", function()
	for _, LocalHumanoid, Networked in world:query(components.LocalHumanoid, components.Networked):iter() do
		local position = LocalHumanoid.root.CFrame.Position
		local _, yRotation, _ = LocalHumanoid.root.CFrame:ToOrientation()

		network.sendLocalPosition.fire({
			position = position,
			yRotation = yRotation,
		})
	end
end)
