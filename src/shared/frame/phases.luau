local jecs = require("@shared/jecs")
local signal = require("@pkg/signal")
local world = require("@shared/world")

local scheduler = require("@shared/scheduler").new(world, {})

export type Context = "server" | "client" | "shared"

export type PhaseNames =
	| "incomingNetwork"
	| "physics"
	| "gameTick"
	| "outgoingNetwork"
	| "input"
	| "animations"
	| "postProcessing"

type PhaseDict = { signal: signal.Identity<number>, entity: jecs.Entity, context: Context }

local function phase(context: Context): PhaseDict
	local signal: signal.Identity<number> = signal()
	local phaseEntity = world:entity()
	world:add(phaseEntity, scheduler.components.Phase)
	world:set(phaseEntity, scheduler.components.Event, signal)

	return {
		signal = signal,
		entity = phaseEntity,
		context = context,
	}
end

local phases = {
	incomingNetwork = phase("shared"),
	physics = phase("shared"),
	gameTick = phase("shared"),
	input = phase("shared"),
	outgoingNetwork = phase("shared"),

	animations = phase("client"),
	postProcessing = phase("client"),
}

phases.scheduler = scheduler

return phases
