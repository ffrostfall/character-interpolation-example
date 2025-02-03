local RENDER_BUFFER = 50 / 1000 -- 50ms

local frame = require("@shared/frame")
local interpolation = require("@shared/interpolation")
local characters = require("@client/characters")
local components = require("@shared/components")
local world = require("@shared/world")

return frame.on("physics", function()
	local interpolated_transforms = interpolation.at(os.clock() - RENDER_BUFFER)
	if not interpolated_transforms then
		return warn("no interpolation result, from extrapolation")
	end

	for network_id, transform in interpolated_transforms do
		local ent = characters.from_id(network_id)
		if not ent then
			continue
		end

		if world:has(ent, components.LocalHumanoid) then
			continue
		end

		world:set(ent, components.Transform, transform)
	end
end)
