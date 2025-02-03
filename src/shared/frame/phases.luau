local jecs = require("@shared/jecs")
local signal = require("@pkg/signal")
local world = require("@shared/world")

local scheduler = require("@shared/scheduler").new(world, {})

export type Context = "server" | "client" | "shared"

export type PhaseNames =
	| "incoming_net"
	| "physics"
	| "game_tick"
	| "outgoing_net"
	| "input"
	| "animations"
	| "postProcessing"

type PhaseDict = { signal: signal.Identity<number>, entity: jecs.Entity, context: Context }

local function phase(context: Context): PhaseDict
	local signal: signal.Identity<number> = signal()
	local ent = world:entity()

	world:add(ent, scheduler.components.Phase)
	world:set(ent, scheduler.components.Event, signal)

	return {
		signal = signal,
		entity = ent,
		context = context,
	}
end

local phases = {
	incoming_net = phase("shared"),
	physics = phase("shared"),
	game_tick = phase("shared"),
	input = phase("shared"),
	outgoing_net = phase("shared"),

	animations = phase("client"),
}

phases.scheduler = scheduler

return phases
