local Players = game:GetService("Players")

local world = require("@shared/world")
local components = require("@shared/components")
local jecs = require("@shared/jecs")
local local_character_rig = require("@shared/characters/local_character_rig")
local remote_character_rig = require("@shared/characters/remote_character_rig")
local network = require("@net/client")

local charactersById: {
	[number]: jecs.Entity,
} = {}

local characters = {}

function characters.init()
	network.add_character_batch.on(function(batch)
		for _, character in batch do
			characters.spawn(character.networkId, character.owner)
		end
	end)
end

function characters.spawn(network_id: number, owner: number?)
	local ent = world:entity()
	local is_local = owner == Players.LocalPlayer.UserId

	print("adding character", network_id, is_local)

	world:set(ent, components.Networked, network_id)

	if is_local then
		characters.spawn_local(ent, network_id)
	else
		characters.spawn_remote(ent, network_id)
	end

	charactersById[network_id] = ent
end

function characters.spawn_local(ent: jecs.Entity, networkId: number)
	local rig = local_character_rig(networkId)

	world:set(ent, components.LocalHumanoid, rig)
	world:set(ent, components.PhysicsTransform, CFrame.identity)
	world:set(ent, components.Model, {
		inst = rig.model,
		primary_part = rig.root,
	})
	world:set(ent, components.HumanoidInput, {
		move_vector = vector.zero,
		camera_vector = vector.zero,
	})

	rig.model.Parent = workspace.characters
end

function characters.spawn_remote(ent: jecs.Entity, networkId: number)
	local rig = remote_character_rig(networkId)

	world:set(ent, components.RemoteHumanoid, rig)
	world:set(ent, components.Model, {
		inst = rig.model,
		primary_part = rig.root,
	})
	world:set(ent, components.Transform, CFrame.new(0, 20, 0))

	rig.model.Parent = workspace.characters
end

function characters.from_id(networkId: number): jecs.Entity?
	return charactersById[networkId]
end

return characters
