local components = require("@shared/components")

return function(network_id: number): components.RemoteHumanoid
	local root_part = Instance.new("Part")
	root_part.Name = "root"
	root_part.Anchored = true
	root_part.Transparency = 0.5
	root_part.Size = vector.create(2, 2, 1)

	local model = Instance.new("Model")
	model.Name = tostring(network_id)

	root_part.Parent = model
	model.PrimaryPart = root_part

	return {
		root = root_part,
		model = model,
	}
end
