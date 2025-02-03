local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local jabby = require("@pkg/jabby")
local network = require("@net/server")
local add_components_under_instance = require("@shared/util/add_components_under_instance")
local world = require("@shared/world")
local data_model = require("@shared/data_model")
local components = require("@shared/components")
local characters = require("@server/characters")
local phases = require("@shared/frame/phases")

require("@shared/systems")
require("@server/systems")

local server = {}

function server.init()
	local startTime = os.clock()

	add_components_under_instance(ReplicatedStorage.shared.components)

	data_model.init()

	RunService.PreSimulation:Connect(function(deltaTime)
		data_model.sync_from()

		phases.incoming_net.signal:fire(deltaTime)
		phases.physics.signal:fire(deltaTime)

		data_model.bulk_update()

		phases.outgoing_net.signal:fire(deltaTime)

		network.stepReplication()
	end)

	phases.scheduler.systems.begin(phases.scheduler.collect.all())

	local end_time = os.clock()

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

	print(`code loaded in {string.format("%.02f", (end_time - startTime) * 1000)}ms`)

	for _, player in Players:GetPlayers() do
		server.add_player(player)
	end

	Players.PlayerAdded:Connect(server.add_player)
end

function server.add_player(player: Player)
	local batch = {}

	for ent, Networked in world:query(components.Networked):iter() do
		local owner = world:get(ent, components.OwnedBy)

		table.insert(batch, {
			networkId = Networked,
			owner = owner and owner.UserId,
		})
	end
	network.add_character_batch.fire(player, batch)

	task.wait(3)

	characters.spawn_character(player, CFrame.new(0, 50, 0))
end

return server
