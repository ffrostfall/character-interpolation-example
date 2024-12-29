--#selene: allow(empty_loop, unused_variable, shadowing)
--!native
--!optimize 2
local jabby = require("@pkg/jabby")
local jecs = require("@shared/jecs")
local luauSignal = require("@pkg/signal")

local pair = jecs.pair
type World = jecs.World
type Entity<T = nil> = jecs.Entity<T>

type System = {
	callback: (deltaTime: number) -> (),
	id: number,
}

type Systems = { System }

type Events = {
	[string]: Systems,
}

export type Scheduler = {
	components: {
		Disabled: Entity,
		System: Entity<System>,
		Phase: Entity,
		DependsOn: Entity,
		Event: Entity<luauSignal.Identity<number>>,
	},

	collect: {
		under_event: (event: Entity) -> Systems,
		all: () -> Events,
	},

	systems: {
		begin: (events: Events) -> { [Entity]: thread },
		new: (callback: (dt: number) -> (), phase: Entity) -> Entity,
	},

	phase: (after: Entity) -> Entity,
}

local scheduler_new: (w: World, components: { [string]: Entity }) -> Scheduler

do
	local world: jecs.World
	local Disabled: jecs.Entity
	local DependsOn: jecs.Entity
	local Phase: jecs.Entity
	local Event: jecs.Entity
	local Name: jecs.Entity<string>
	local System: jecs.Entity<{ callback: (...any) -> ...any, name: string }>

	local scheduler

	local system: System
	local deltaTime: number
	local function run(...): ...any
		local id = system.id
		local system_data = scheduler.system_data[id]
		if system_data.paused then return end

		scheduler:run(id, system.callback, deltaTime)
		-- scheduler:mark_system_frame_start(id)
		-- system.callback(deltaTime)
		-- scheduler:mark_system_frame_end(id)
	end
	local function panic(str)
		-- We don't want to interrupt the loop when we error
		task.spawn(error, str)
	end
	local function begin(events: { [luauSignal.Identity<number>]: Systems })
		local connections = {}
		for event, systems in events do
			if not event then continue end

			local event_name = `{event}`
			connections[event_name] = (event :: any):connect(function(passedDeltaTime: number)
				deltaTime = passedDeltaTime

				debug.profilebegin(event_name)
				for _, sys in systems do
					system = sys
					local didNotYield, why = xpcall(function()
						for _ in run do
						end
					end, debug.traceback)

					if didNotYield then continue end

					if string.find(why, "thread is not yieldable") then
						panic(
							"Not allowed to yield in the systems."
									.. "\n"
									.. "System: "
									.. debug.info(system.callback, "s")
								or "<anonymous>" .. " has been ejected"
						)
						continue
					end
					panic(why)
				end
				debug.profileend()
			end)
		end

		return connections
	end

	local function scheduler_collect_systems_under_phase_recursive(systems, phase)
		local phase_name = world:get(phase, Name)
		for _, system in world:query(System):with(pair(DependsOn, phase)):iter() do
			table.insert(systems, {
				id = scheduler:register_system({
					name = system.name,
					phase = phase_name,
				}),
				callback = system.callback,
			})
		end
		for after in world:query(Phase):with(pair(DependsOn, phase)):iter() do
			scheduler_collect_systems_under_phase_recursive(systems, after)
		end
	end

	local function scheduler_collect_systems_under_event(event)
		local systems = {}
		scheduler_collect_systems_under_phase_recursive(systems, event)
		return systems
	end

	local function scheduler_collect_systems_all()
		local events = {}
		for phase, event in world:query(Event):with(Phase):iter() do
			events[event] = scheduler_collect_systems_under_event(phase)
		end
		return events
	end

	local function scheduler_phase_new(after)
		local phase = world:entity()
		world:add(phase, Phase)
		local dependency = pair(DependsOn, after)
		world:add(phase, dependency)
		return phase
	end

	local function scheduler_systems_new(callback: () -> (), phase: Entity)
		local system = world:entity()
		local scriptName = debug.info(callback, "s")
		local name = string.match(scriptName, "%.(%w+)$") or scriptName
		world:set(system, System, { callback = callback, name = name })
		world:add(system, pair(DependsOn, phase))
		return system
	end

	function scheduler_new(w: World, components: { [string]: Entity })
		world = w
		Disabled = world:component()
		System = world:component()
		Phase = world:component()
		DependsOn = world:component()
		Event = world:component()
		Name = world:component()

		for name, component in components do
			world:set(component, Name, name)
		end

		scheduler = jabby.scheduler.create("scheduler")

		table.insert(jabby.public, scheduler)
		return {
			phase = scheduler_phase_new,

			world = world,

			components = {
				DependsOn = DependsOn,
				Disabled = Disabled,
				Phase = Phase,
				System = System,
				Event = Event,
			},

			collect = {
				under_event = scheduler_collect_systems_under_event,
				all = scheduler_collect_systems_all,
			},

			systems = {
				new = scheduler_systems_new,
				begin = begin,
			},
		}
	end
end

return {
	new = scheduler_new,
}
