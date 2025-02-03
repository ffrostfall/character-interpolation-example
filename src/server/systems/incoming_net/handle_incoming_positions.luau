local frame = require("@shared/frame")
local network = require("@net/server")
local world = require("@shared/world")
local characters = require("@server/characters")
local components = require("@shared/components")

return frame.on("incoming_net", function()
	for _, player, transform in network.send_local_position.iter() do
		local ent = characters.from_player(player)
		if not ent then
			continue
		end

		local position = transform.position
		local rotation = transform.y_rot
		local sin, cos = math.sin(rotation), math.cos(rotation)

		--stylua: ignore
		local coordinate_frame = CFrame.new(
			position.X, position.Y, position.Z,
			cos, 0, sin,
			0, 1, 0,
			-sin, 0, cos
		)
		--stylua: endignore

		world:set(ent, components.Transform, coordinate_frame)
	end
end)
