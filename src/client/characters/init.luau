local Players = game:GetService("Players")

local world = require("@shared/world")
local components = require("@shared/components")
local jecs = require("@shared/jecs")
local localCharacterRig = require("@shared/characters/localCharacterRig")
local remoteCharacterRig = require("@shared/characters/remoteCharacterRig")
local network = require("@network/client")

local charactersById: {
	[number]: jecs.Entity,
} = {}

local characters = {}

function characters.init()
	network.addCharacterBatch.on(function(batch)
		for _, character in batch do
			characters.spawn(character.networkId, character.owner)
		end
	end)
end

function characters.spawn(networkId: number, owner: number?)
	local ent = world:entity()
	local isLocal = owner == Players.LocalPlayer.UserId

	print("adding character", networkId, isLocal)

	world:set(ent, components.Networked, networkId)

	if isLocal then
		characters.spawnLocal(ent, networkId)
	else
		characters.spawnRemote(ent, networkId)
	end

	charactersById[networkId] = ent
end

function characters.spawnLocal(ent: jecs.Entity, networkId: number)
	local rig = localCharacterRig(networkId)

	world:set(ent, components.LocalHumanoid, rig)
	world:set(ent, components.PhysicsTransform, CFrame.identity)
	world:set(ent, components.Model, {
		inst = rig.model,
		primaryPart = rig.root,
	})
	world:set(ent, components.HumanoidInput, {
		moveVector = vector.zero,
		cameraVector = vector.zero,
	})

	rig.model.Parent = workspace.characters
end

function characters.spawnRemote(ent: jecs.Entity, networkId: number)
	local rig = remoteCharacterRig(networkId)

	world:set(ent, components.RemoteHumanoid, rig)
	world:set(ent, components.Model, {
		inst = rig.model,
		primaryPart = rig.root,
	})
	world:set(ent, components.Transform, CFrame.new(0, 20, 0))

	rig.model.Parent = workspace.characters
end

function characters.fromId(networkId: number): jecs.Entity?
	return charactersById[networkId]
end

return characters
