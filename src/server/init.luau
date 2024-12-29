local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

ReplicatedStorage:WaitForChild("Packages")
ReplicatedStorage.Packages:WaitForChild("_Index")

local jabby = require("@pkg/jabby")
local logger = require("@shared/logger")
local network = require("@network/server")
local registerComponentsUnderInstance = require("@shared/util/registerComponentsUnderInstance")
local world = require("@shared/world")
local dataModel = require("@shared/dataModel")
local components = require("@shared/components")
local characters = require("@server/characters")
local phases = require("@shared/frame/phases")

local loggerObject = logger.new("server")

require("@shared/systems")
require("@server/systems")

local server = {}

function server.init()
	local startTime = os.clock()

	registerComponentsUnderInstance(ReplicatedStorage.shared.components)

	dataModel.init()

	RunService.PreSimulation:Connect(function(deltaTime)
		dataModel.syncFrom()

		phases.incomingNetwork.signal:fire(deltaTime)

		phases.physics.signal:fire(deltaTime)

		dataModel.bulkUpdateCFrame()

		phases.outgoingNetwork.signal:fire(deltaTime)

		network.stepReplication()
	end)

	phases.scheduler.systems.begin(phases.scheduler.collect.all())

	local endTime = os.clock()

	jabby.set_check_function(function()
		return true
	end)

	table.insert(jabby.public, {
		class_name = "World",
		name = "main",
		world = world,
		debug = components.Debug,
		entities = {},
	})
	jabby.public.updated = true

	loggerObject:warn(`code loaded in {string.format("%.02f", (endTime - startTime) * 1000)}ms`)

	for _, player in Players:GetPlayers() do
		server.addPlayer(player)
	end

	Players.PlayerAdded:Connect(server.addPlayer)
	Players.PlayerRemoving:Connect(server.removePlayer)
end

function server.addPlayer(player: Player)
	local batch = {}
	for ent, Networked in world:query(components.Networked):iter() do
		local owner = world:get(ent, components.OwnedBy)

		table.insert(batch, {
			networkId = Networked,
			owner = owner and owner.UserId,
		})
	end
	network.addCharacterBatch.fire(player, batch)

	task.wait(3)

	characters.spawnCharacter(player, CFrame.new(0, 50, 0))
end

function server.removePlayer(player: Player) end

return server
