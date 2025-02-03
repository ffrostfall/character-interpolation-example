local network = require("@net/server")
local components = require("@shared/components")
local world = require("@shared/world")
local network_id = require("@server/network_id")
local create_anchored_rig = require("@shared/rigs/create_anchored_rig")
local create_simulated_rig = require("@shared/rigs/create_simulated_rig")
local jecs = require("@shared/jecs")

local player_character_map: { [Player]: jecs.Entity } = {}

local character = {}

function character.spawn_character(owner: Player?, spawn_location: CFrame)
	local ent = world:entity()
	local id = network_id.getId()

	world:set(ent, components.Networked, id)
	print("adding character", owner, spawn_location, id)

	if owner then
		character.spawn_remote(ent, id, owner, spawn_location)
	else
		character.spawn_local(ent, id)
	end

	network.add_character_batch.fireAll({ {
		networkId = id,
		owner = owner and owner.UserId,
	} })
end

function character.spawn_remote(ent: jecs.Entity, id: number, owner: Player, spawn_location: CFrame)
	local rig = create_anchored_rig()

	world:set(ent, components.AnchoredRig, rig)
	world:set(ent, components.PrimaryPart, rig.root)
	world:set(ent, components.Transform, spawn_location)
	world:set(ent, components.OwnedBy, owner)

	rig.model.Parent = workspace.server_simulation
	player_character_map[owner] = ent
end

function character.spawn_local(ent: jecs.Entity, network_id: number)
	local rig = create_simulated_rig()
	rig.model.Name = tostring(network_id)

	world:set(ent, components.SimulatedRig, rig)

	world:set(ent, components.PrimaryPart, rig.root)
	world:set(ent, components.Physics)

	world:set(ent, components.Input, {
		move_vector = vector.zero,
		camera_vector = vector.zero,
	})

	rig.model.Parent = workspace.server_simulation
end

function character.from_player(player: Player): jecs.Entity?
	return player_character_map[player]
end

return character
