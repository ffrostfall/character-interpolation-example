local Players = game:GetService("Players")

local world = require("@shared/world")
local components = require("@shared/components")
local jecs = require("@shared/jecs")
local create_simulated_rig = require("@shared/rigs/create_simulated_rig")
local create_anchored_rig = require("@shared/rigs/create_anchored_rig")
local network = require("@net/client")

local characters_by_id: {
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

	characters_by_id[network_id] = ent
end

function characters.spawn_local(ent: jecs.Entity, network_id: number)
	local rig = create_simulated_rig()
	rig.model.Name = tostring(network_id)

	world:set(ent, components.SimulatedRig, rig)
	world:set(ent, components.Transform, CFrame.new(0, 50, 0))
	world:set(ent, components.PrimaryPart, rig.root)
	world:add(ent, components.Physics)

	world:set(ent, components.Input, {
		move_vector = vector.zero,
		camera_vector = vector.zero,
	})

	rig.model.Parent = workspace.characters
end

function characters.spawn_remote(ent: jecs.Entity, network_id: number)
	local rig = create_anchored_rig()
	rig.model.Name = tostring(network_id)

	world:set(ent, components.AnchoredRig, rig)
	world:set(ent, components.PrimaryPart, rig.root)
	world:set(ent, components.Transform, CFrame.new(0, 20, 0))

	rig.model.Parent = workspace.characters
end

function characters.from_id(network_id: number): jecs.Entity?
	return characters_by_id[network_id]
end

return characters
