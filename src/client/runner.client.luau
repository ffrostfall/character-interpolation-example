local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local jabby = require("@pkg/jabby")
local network = require("@net/client")
local add_components_under_instance = require("@shared/util/add_components_under_instance")
local world = require("@shared/world")
local data_model = require("@shared/data_model")
local phases = require("@shared/frame/phases")
local input = require("@client/input")
local characters = require("@client/characters")
local controls = require("@client/controls")
local require_descendants = require("@shared/util/require_descendants")

require_descendants(ReplicatedStorage.client.systems)
require_descendants(ReplicatedStorage.shared.systems)

local client = {}

function client.init()
	local startTime = os.clock()

	add_components_under_instance(ReplicatedStorage.shared.components)

	data_model.init()

	RunService.RenderStepped:Connect(function(deltaTime)
		phases.input.signal:fire(deltaTime)
		phases.animations.signal:fire(deltaTime)
	end)

	RunService.PreSimulation:Connect(function(deltaTime)
		phases.incoming_net.signal:fire(deltaTime)

		data_model.sync_from()

		phases.physics.signal:fire(deltaTime)

		data_model.bulk_update()

		phases.outgoing_net.signal:fire(deltaTime)

		network.stepReplication()
	end)

	phases.scheduler.systems.begin(phases.scheduler.collect.all())

	local endTime = os.clock()

	jabby.set_check_function(function()
		return true
	end)

	input.init()
	characters.init()

	table.insert(jabby.public, {
		class_name = "World",
		name = "main",
		world = world,
		entities = {},
	})
	jabby.public.updated = true

	print(`code loaded in {string.format("%.02f", (endTime - startTime) * 1000)}ms`)

	local jabby_client = jabby.obtain_client() :: any

	controls.DEBUGGER.tapped:connect(function()
		jabby_client.spawn_app(jabby_client.apps.home)
	end)
end

client.init()
