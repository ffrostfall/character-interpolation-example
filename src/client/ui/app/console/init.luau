local vide = require("@pkg/vide")
local container = require("@ui/components/base/container")

return function()
	return container({
		position = UDim2.fromScale(0.5, 0.5),
		size = UDim2.fromScale(0.5, 0.5),

		children = {},
	})
end
