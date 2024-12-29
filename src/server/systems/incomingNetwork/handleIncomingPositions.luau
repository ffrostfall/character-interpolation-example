local frame = require("@shared/frame")
local network = require("@network/server")
local world = require("@shared/world")
local characters = require("@server/characters")
local components = require("@shared/components")

return frame.on("incomingNetwork", function()
	for _, player, transform in network.sendLocalPosition.iter() do
		local ent = characters.fromPlayer(player)
		if not ent then
			continue
		end

		local position = transform.position
		local rotation = transform.yRotation
		local sin, cos = math.sin(rotation), math.cos(rotation)

		world:set(
			ent,
			components.Transform,
			CFrame.new(position.X, position.Y, position.Z, cos, 0, sin, 0, 1, 0, -sin, 0, cos)
		)
	end
end)
