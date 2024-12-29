local HEAD_HEIGHT = vector.create(0, 1.5, 0)

local UserInputService = game:GetService("UserInputService")

local frame = require("@shared/frame")
local world = require("@shared/world")
local components = require("@shared/components")

return frame.on("input", function()
	local delta = UserInputService:GetMouseDelta()

	for _, HumanoidInput, LocalHumanoid in world:query(components.HumanoidInput, components.LocalHumanoid):iter() do
		HumanoidInput.cameraVector = vector.create(
			math.clamp(HumanoidInput.cameraVector.X + delta.Y, -90, 90),
			(HumanoidInput.cameraVector.Y + delta.X) % 361,
			0
		)

		local cameraPos = LocalHumanoid.root.Position + HEAD_HEIGHT
		local yRot = math.rad(HumanoidInput.cameraVector.Y)
		local cameraCFrame = CFrame.new(cameraPos)
			* (CFrame.Angles(0, -yRot, 0))
			* CFrame.Angles(-math.rad(HumanoidInput.cameraVector.X), 0, 0)

		workspace.CurrentCamera.CFrame = cameraCFrame
	end
end)
