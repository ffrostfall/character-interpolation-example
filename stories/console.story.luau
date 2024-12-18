local uilabs = require("@pkg/ui-labs")
local vide = require("@pkg/vide")
local console = require("@ui/app/console")

return uilabs.CreateVideStory({
	vide = vide,
	controls = {
		color = {},
	},
}, function(target)
	console()

	return function()
		return
	end
end)
