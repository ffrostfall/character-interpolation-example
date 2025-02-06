local frame = require("@shared/frame")
local network = require("@net/server")
local world = require("@shared/world")
local components = require("@shared/components")

return frame.on("outgoing_net", function()
	local timestamp = workspace:GetServerTimeNow()

	local transforms: { [number]: network.CharacterTransform } = {}
	local snapshot: network.Snapshot = {
		timestamp = timestamp,

		transforms = transforms,
	}

	for _, Networked, Transform in world:query(components.Networked, components.Transform):iter() do
		local _, y_rot, _ = Transform:ToOrientation()

		transforms[Networked] = {
			position = Transform.Position,
			y_rot = y_rot,
		}
	end

	network.send_snapshot.fireAll(snapshot)
end)
