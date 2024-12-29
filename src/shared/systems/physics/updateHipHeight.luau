local HIP_HEIGHT = 3.3
local DIRECTION = vector.create(0, -1, 0) * HIP_HEIGHT

local frame = require("@shared/frame")
local world = require("@shared/world")
local components = require("@shared/components")

local rayParams = RaycastParams.new()
rayParams.FilterDescendantsInstances = { workspace.characters }
rayParams.FilterType = Enum.RaycastFilterType.Exclude

return frame.on("physics", function()
	for _, LocalHumanoid in world:query(components.LocalHumanoid):iter() do
		local result = workspace:Blockcast(LocalHumanoid.root.CFrame, LocalHumanoid.root.Size, DIRECTION, rayParams)

		if result then
			LocalHumanoid.position.Enabled = true

			LocalHumanoid.position.Position = result.Position + vector.create(0, HIP_HEIGHT, 0)
		else
			LocalHumanoid.position.Enabled = false
		end
	end
end)
