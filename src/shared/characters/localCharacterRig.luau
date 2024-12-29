local components = require("@shared/components")

return function(networkId: number): components.LocalHumanoid
	local humanoidRootPart = Instance.new("Part")
	humanoidRootPart.Name = "root"
	humanoidRootPart.Anchored = false
	humanoidRootPart.Transparency = 0.5
	humanoidRootPart.Size = vector.create(2, 2, 1)

	local attachment = Instance.new("Attachment")
	attachment.Name = "attachment"
	attachment.Parent = humanoidRootPart

	local orientation = Instance.new("AlignOrientation")
	orientation.Name = "orientation"
	orientation.RigidityEnabled = true
	orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	orientation.Attachment0 = attachment
	orientation.Parent = humanoidRootPart

	local position = Instance.new("AlignPosition")
	position.Name = "position"
	position.Mode = Enum.PositionAlignmentMode.OneAttachment
	position.ForceRelativeTo = Enum.ActuatorRelativeTo.World
	position.Attachment0 = attachment
	position.Responsiveness = 200
	position.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	position.ApplyAtCenterOfMass = true
	position.MaxAxesForce = vector.create(0, 10000, 0)
	position.Parent = humanoidRootPart

	local movement = Instance.new("LinearVelocity")
	movement.Name = "movement"
	movement.Attachment0 = attachment
	movement.MaxAxesForce = vector.create(10000, 0, 10000)
	movement.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	movement.Parent = humanoidRootPart

	local model = Instance.new("Model")
	model.Name = tostring(networkId)

	humanoidRootPart.Parent = model
	model.PrimaryPart = humanoidRootPart

	return {
		root = humanoidRootPart,
		attachment = attachment,
		orientation = orientation,
		position = position,
		movement = movement,
		model = model,
	}
end
