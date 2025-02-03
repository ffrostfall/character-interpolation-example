local jecs = require("@shared/jecs")
local component = require("@shared/util/component")
local networkTypes = require("@net/types")

export type AnchoredRig = {
	root: Part,
	model: Model,
}

export type SimulatedRig = {
	orientation: AlignOrientation,
	attachment: Attachment,
	root: Part,
	position: AlignPosition,
	movement: LinearVelocity,
	model: Model,
}

export type Input = {
	camera_vector: vector,
	move_vector: vector,
}

return {
	Networked = component.new() :: jecs.Entity<networkTypes.NetworkId>,

	AnchoredRig = component.new() :: jecs.Entity<AnchoredRig>,
	SimulatedRig = component.new() :: jecs.Entity<SimulatedRig>,
	Input = component.new() :: jecs.Entity<Input>,

	OwnedBy = component.new() :: jecs.Entity<Player>,

	PrimaryPart = component.new() :: jecs.Entity<BasePart>,
	Physics = component.new() :: jecs.Entity,

	Transform = component.new() :: jecs.Entity<CFrame>,
}
