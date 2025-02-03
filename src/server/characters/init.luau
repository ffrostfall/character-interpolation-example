local network = require("@net/server")
local components = require("@shared/components")
local world = require("@shared/world")
local network_id = require("@server/network_id")
local remote_character_rig = require("@shared/characters/remote_character_rig")
local local_character_rig = require("@shared/characters/local_character_rig")
local jecs = require("@shared/jecs")

local player_character_map: { [Player]: jecs.Entity } = {}

local character = {}

function character.spawn_character(owner: Player?, spawn_location: CFrame)
	local ent = world:entity()
	local id = network_id.getId()

	world:set(ent, components.Networked, id)

	print("adding character", owner, spawn_location, id)

	if owner then
		local rig = remote_character_rig(id)

		world:set(ent, components.RemoteHumanoid, rig)
		world:set(ent, components.Model, {
			primary_part = rig.root,
			inst = rig.model,
		})
		world:set(ent, components.Transform, spawn_location)
		world:set(ent, components.OwnedBy, owner)

		rig.model.Parent = workspace.server_simulation
		player_character_map[owner] = ent
	else
		local rig = local_character_rig(id)

		world:set(ent, components.LocalHumanoid, rig)
		world:set(ent, components.HumanoidInput, {
			move_vector = vector.zero,
			camera_vector = vector.zero,
		})
		world:set(ent, components.Model, {
			primary_part = rig.root,
			inst = rig.model,
		})

		world:set(ent, components.PhysicsTransform, rig.root.CFrame)

		rig.model.Parent = workspace.server_simulation
	end

	network.add_character_batch.fireAll({ {
		networkId = id,
		owner = owner and owner.UserId,
	} })
end

function character.from_player(player: Player): jecs.Entity?
	return player_character_map[player]
end

return character
