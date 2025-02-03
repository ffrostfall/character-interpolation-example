local components = require("@shared/components")
local frame = require("@shared/frame")
local world = require("@shared/world")

return frame.on("physics", function()
	for _, LocalHumanoid, HumanoidInput in world:query(components.LocalHumanoid, components.HumanoidInput):iter() do
		local new_attachment_coordinate_frame = CFrame.fromEulerAnglesXYZ(0, math.rad(HumanoidInput.camera_vector.Y), 0)

		LocalHumanoid.attachment.CFrame = new_attachment_coordinate_frame
	end
end)
