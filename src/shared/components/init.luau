local jecs = require("@shared/jecs")
local component = require("@shared/util/component")
local networkTypes = require("@network/types")

export type RemoteHumanoid = {
	root: Part,
	model: Model,
}

export type LocalHumanoid = {
	orientation: AlignOrientation,
	attachment: Attachment,
	root: Part,
	position: AlignPosition,
	movement: LinearVelocity,
	model: Model,
}

export type HumanoidInput = {
	cameraVector: vector,
	moveVector: vector,
}

return {
	Debug = component.new() :: jecs.Entity<>,

	HumanoidInput = component.new() :: jecs.Entity<HumanoidInput>,

	RemoteHumanoid = component.new() :: jecs.Entity<RemoteHumanoid>,
	OwnedBy = component.new() :: jecs.Entity<Player>,
	LocalHumanoid = component.new() :: jecs.Entity<LocalHumanoid>,

	-- All models are required to have a primarypart
	Model = component.new() :: jecs.Entity<{
		inst: Model,
		primaryPart: BasePart,
	}>,

	-- Changing Transform is going to add the models primarypart and the models cframe to the bulkmoveto queue
	Transform = component.new() :: jecs.Entity<CFrame>,

	-- Read-only transform value taken from a physically simulated model
	PhysicsTransform = component.new() :: jecs.Entity<CFrame>,

	Networked = component.new() :: jecs.Entity<networkTypes.NetworkId>,
}
