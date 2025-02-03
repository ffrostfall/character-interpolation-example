local components = require("@shared/components")

return function(): components.SimulatedRig
	local root_part = Instance.new("Part")
	root_part.Name = "root"
	root_part.Anchored = false
	root_part.Transparency = 0.5
	root_part.Size = vector.create(2, 2, 1)

	local attachment = Instance.new("Attachment")
	attachment.Name = "attachment"
	attachment.Parent = root_part

	local orientation = Instance.new("AlignOrientation")
	orientation.Name = "orientation"
	orientation.RigidityEnabled = true
	orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	orientation.Attachment0 = attachment
	orientation.Parent = root_part

	local position = Instance.new("AlignPosition")
	position.Name = "position"
	position.Mode = Enum.PositionAlignmentMode.OneAttachment
	position.ForceRelativeTo = Enum.ActuatorRelativeTo.World
	position.Attachment0 = attachment
	position.Responsiveness = 200
	position.ForceLimitMode = Enum.ForceLimitMode.PerAxis
	position.ApplyAtCenterOfMass = true
	position.MaxAxesForce = vector.create(0, 10000, 0)
	position.Parent = root_part

	local movement = Instance.new("LinearVelocity")
	movement.Name = "movement"
	movement.Attachment0 = attachment
	movement.MaxAxesForce = vector.create(10000, 0, 10000)
	movement.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	movement.Parent = root_part

	local model = Instance.new("Model")

	root_part.Parent = model

	return {
		root = root_part,
		attachment = attachment,
		orientation = orientation,
		position = position,
		movement = movement,
		model = model,
	}
end
