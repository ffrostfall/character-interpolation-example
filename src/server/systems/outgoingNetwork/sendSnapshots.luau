local frame = require("@shared/frame")
local network = require("@network/server")
local world = require("@shared/world")
local components = require("@shared/components")

return frame.on("outgoingNetwork", function()
	local timestamp = workspace:GetServerTimeNow()

	local transforms: { [number]: network.CharacterTransform } = {}
	local snapshot: network.Snapshot = {
		timestamp = timestamp,

		transforms = transforms,
	}

	for _, Networked, Transform in world:query(components.Networked, components.Transform):iter() do
		local _, yRotation, _ = Transform:ToOrientation()

		transforms[Networked] = {
			position = Transform.Position,
			yRotation = yRotation,
		}
	end

	for _, Networked, PhysicsTransform in world:query(components.Networked, components.PhysicsTransform):iter() do
		local _, yRotation, _ = PhysicsTransform:ToOrientation()

		transforms[Networked] = {
			position = PhysicsTransform.Position,
			yRotation = yRotation,
		}
	end

	network.sendSnapshot.fireAll(snapshot)
end)
