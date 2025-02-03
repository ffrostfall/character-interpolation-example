local HEAD_HEIGHT = vector.create(0, 1.5, 0)
local CAMERA_SENS = vector.create(1, 0.77, 0)
local INVERT_MOUSE = vector.create(1, -1, 0)

local UserGameSettings = UserSettings():GetService("UserGameSettings")

local frame = require("@shared/frame")
local world = require("@shared/world")
local components = require("@shared/components")
local mouse = require("@client/input/mouse")

return frame.on("input", function()
	local input_vector = mouse.read_delta() * CAMERA_SENS

	if UserGameSettings:GetCameraYInvertValue() then
		input_vector *= INVERT_MOUSE
	end

	for _, HumanoidInput, LocalHumanoid in world:query(components.Input, components.SimulatedRig):iter() do
		local existing_camera_vector = HumanoidInput.camera_vector

		HumanoidInput.camera_vector = vector.create(
			math.clamp(existing_camera_vector.X + input_vector.Y, -89, 89),
			(existing_camera_vector.Y + input_vector.X) % 360,
			0
		)

		local coordinate_frame =
			CFrame.fromEulerAnglesYXZ(-HumanoidInput.camera_vector.X, -HumanoidInput.camera_vector.Y, 0)

		workspace.CurrentCamera.CFrame = CFrame.new(LocalHumanoid.root.Position + HEAD_HEIGHT) * coordinate_frame
	end
end)
