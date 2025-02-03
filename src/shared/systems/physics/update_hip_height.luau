local HIP_HEIGHT = 3.3
local DIRECTION = vector.create(0, -1, 0) * HIP_HEIGHT
local HIP_HEIGHT_VECTOR = vector.create(0, HIP_HEIGHT, 0)

local frame = require("@shared/frame")
local world = require("@shared/world")
local components = require("@shared/components")

local ray_params = RaycastParams.new()
ray_params.FilterDescendantsInstances = { workspace.characters }
ray_params.FilterType = Enum.RaycastFilterType.Exclude

return frame.on("physics", function()
	for _, LocalHumanoid in world:query(components.LocalHumanoid):iter() do
		local hit_floor = workspace:Blockcast(LocalHumanoid.root.CFrame, LocalHumanoid.root.Size, DIRECTION, ray_params)

		LocalHumanoid.position.Enabled = hit_floor ~= nil

		if hit_floor then
			LocalHumanoid.position.Position = hit_floor.Position + HIP_HEIGHT_VECTOR
		end
	end
end)
