local components = require("@shared/components")
local frame = require("@shared/frame")
local world = require("@shared/world")

return frame.on("physics", function()
	for _, LocalHumanoid, HumanoidInput in world:query(components.LocalHumanoid, components.HumanoidInput):iter() do
		LocalHumanoid.attachment.CFrame = CFrame.Angles(0, math.rad(HumanoidInput.cameraVector.Y), 0)
	end
end)
