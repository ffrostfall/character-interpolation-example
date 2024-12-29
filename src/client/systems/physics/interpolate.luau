local RENDER_BUFFER = 50 / 1000 -- 50ms

local frame = require("@shared/frame")
local interpolation = require("@shared/interpolation")
local characters = require("@client/characters")
local components = require("@shared/components")
local world = require("@shared/world")

return frame.on("physics", function()
	local interpolated = interpolation.at(os.clock() - RENDER_BUFFER)
	if not interpolated then
		return warn("no interpolation result, from extrapolation")
	end

	for networkId, transform in interpolated do
		local ent = characters.fromId(networkId)
		if not ent then
			continue
		end

		if world:has(ent, components.LocalHumanoid) then
			continue
		end

		world:set(ent, components.Transform, transform)
	end
end)
