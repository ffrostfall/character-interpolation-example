local UserInputService = game:GetService("UserInputService")

local frame = require("@shared/frame")
local world = require("@shared/world")
local components = require("@shared/components")

return frame.on("input", function()
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default

	for _ in world:query(components.LocalHumanoid):iter() do
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
end)
