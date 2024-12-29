local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

ReplicatedStorage:WaitForChild("Packages")
ReplicatedStorage.Packages:WaitForChild("_Index")

local _systems = require("@client/systems")
local jabby = require("@pkg/jabby")
local logger = require("@shared/logger")
local network = require("@network/client")
local registerComponentsUnderInstance = require("@shared/util/registerComponentsUnderInstance")
local world = require("@shared/world")
local dataModel = require("@shared/dataModel")
local components = require("@shared/components")
local phases = require("@shared/frame/phases")
local input = require("@client/input")
local characters = require("@client/characters")
local controls = require("@client/controls")

local loggerObject = logger.new("client")

require("@shared/systems")
require("@client/systems")

local client = {}

function client.init()
	local startTime = os.clock()

	registerComponentsUnderInstance(ReplicatedStorage.shared.components)

	dataModel.init()

	RunService.RenderStepped:Connect(function(deltaTime)
		phases.input.signal:fire(deltaTime)
		phases.animations.signal:fire(deltaTime)
	end)

	RunService.PreSimulation:Connect(function(deltaTime)
		phases.incomingNetwork.signal:fire(deltaTime)

		dataModel.syncFrom()

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

	input.init()
	characters.init()

	table.insert(jabby.public, {
		class_name = "World",
		name = "main",
		world = world,
		debug = components.Debug,
		entities = {},
	})
	jabby.public.updated = true

	loggerObject:warn(`code loaded in {string.format("%.02f", (endTime - startTime) * 1000)}ms`)

	local jabbyclient = jabby.obtain_client() :: any

	controls.DEBUGGER.tapped:connect(function()
		jabbyclient.spawn_app(jabbyclient.apps.home)
	end)
end

return client
