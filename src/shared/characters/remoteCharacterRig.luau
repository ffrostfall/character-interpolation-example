local components = require("@shared/components")

return function(networkId: number): components.RemoteHumanoid
	local humanoidRootPart = Instance.new("Part")
	humanoidRootPart.Name = "root"
	humanoidRootPart.Anchored = true
	humanoidRootPart.Transparency = 0.5
	humanoidRootPart.Size = vector.create(2, 2, 1)

	local model = Instance.new("Model")
	model.Name = tostring(networkId)

	humanoidRootPart.Parent = model
	model.PrimaryPart = humanoidRootPart

	return {
		root = humanoidRootPart,
		model = model,
	}
end
