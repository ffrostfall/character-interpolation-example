local network = require("@network/server")
local components = require("@shared/components")
local world = require("@shared/world")
local networkId = require("@server/networkId")
local remoteCharacterRig = require("@shared/characters/remoteCharacterRig")
local localCharacterRig = require("@shared/characters/localCharacterRig")
local jecs = require("@shared/jecs")

local playerCharacterMap: { [Player]: jecs.Entity } = {}

local character = {}

function character.spawnCharacter(owner: Player?, spawnLocation: CFrame)
	local ent = world:entity()
	local id = networkId.getId()

	world:set(ent, components.Networked, id)

	print("adding character", owner, spawnLocation, id)

	if owner then
		local rig = remoteCharacterRig(id)

		world:set(ent, components.RemoteHumanoid, rig)
		world:set(ent, components.Model, {
			primaryPart = rig.root,
			inst = rig.model,
		})
		world:set(ent, components.Transform, spawnLocation)
		world:set(ent, components.OwnedBy, owner)

		rig.model.Parent = workspace.serverSimulation
		playerCharacterMap[owner] = ent
	else
		local rig = localCharacterRig(id)

		world:set(ent, components.LocalHumanoid, rig)
		world:set(ent, components.HumanoidInput, {
			moveVector = vector.zero,
			cameraVector = vector.zero,
		})
		world:set(ent, components.Model, {
			primaryPart = rig.root,
			inst = rig.model,
		})

		world:set(ent, components.PhysicsTransform, rig.root.CFrame)

		rig.model.Parent = workspace.serverSimulation
	end

	network.addCharacterBatch.fireAll({ {
		networkId = id,
		owner = owner and owner.UserId,
	} })
end

function character.fromPlayer(player: Player): jecs.Entity?
	return playerCharacterMap[player]
end

return character
