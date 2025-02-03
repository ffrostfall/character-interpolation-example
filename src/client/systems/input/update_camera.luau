local HEAD_HEIGHT = vector.create(0, 1.5, 0)

local UserInputService = game:GetService("UserInputService")

local frame = require("@shared/frame")
local world = require("@shared/world")
local components = require("@shared/components")

return frame.on("input", function()
	local delta = UserInputService:GetMouseDelta()

	for _, HumanoidInput, LocalHumanoid in world:query(components.HumanoidInput, components.LocalHumanoid):iter() do
		HumanoidInput.camera_vector = vector.create(
			math.clamp(HumanoidInput.camera_vector.X + delta.Y, -90, 90),
			(HumanoidInput.camera_vector.Y + delta.X) % 361,
			0
		)

		local cameraPos = LocalHumanoid.root.Position + HEAD_HEIGHT
		local yRot = math.rad(HumanoidInput.camera_vector.Y)
		local cameraCFrame = CFrame.new(cameraPos)
			* (CFrame.Angles(0, -yRot, 0))
			* CFrame.Angles(-math.rad(HumanoidInput.camera_vector.X), 0, 0)

		workspace.CurrentCamera.CFrame = cameraCFrame
	end
end)
