local UserInputService = game:GetService("UserInputService")

local mouse = require("./mouse")
local signal = require("@pkg/signal")
local symbolize_input = require("./symbolize_input")

export type TapActionConfig = {
	kind: "tap",
	input: symbolize_input.InputSymbol,
}

export type HoldActionConfig = {
	kind: "hold",
	input: symbolize_input.InputSymbol,
	hold_duration: number,
}

type RegisterActionFunction = (config: TapActionConfig) -> () | (config: HoldActionConfig) -> ()

type TapAction = Action & {
	tapped: signal.Identity<()>,
	kind: "tap",
}
local function tap_action(default_input_symbol: symbolize_input.InputSymbol): TapAction
	return {
		tapped = signal(),

		input = default_input_symbol,
		kind = "tap" :: "tap",
	}
end

type long_pressAction = Action & {
	started: signal.Identity<()>,
	ended: signal.Identity<()>,
	cancelled: signal.Identity<()>,

	kind: "long_press",
	_pressed: number,
}
local function long_press_action(default_input_symbol: symbolize_input.InputSymbol): long_pressAction
	return {
		started = signal(),
		ended = signal(),
		cancelled = signal(),

		input = default_input_symbol,
		kind = "long_press" :: "long_press",
		_pressed = 0,
	}
end

type HeldAction = Action & {
	being_held: boolean,

	kind: "held",
}
local function held_action(default_input_symbol: symbolize_input.InputSymbol): HeldAction
	return {
		being_held = false,

		input = default_input_symbol,
		kind = "held" :: "held",
	}
end

type Action = {
	input: symbolize_input.InputSymbol,
}
type AnyAction = TapAction | long_pressAction | HeldAction

local active_sink_thread: thread?
local input_symbol_to_action: { [symbolize_input.InputSymbol]: AnyAction } = {}
local queue = {}

local input = {}

function input.init()
	mouse.init()

	UserInputService.InputBegan:Connect(input._insert_into_queue)
	UserInputService.InputEnded:Connect(input._insert_into_queue)
end

function input.is_key_down(keyCode: Enum.KeyCode): boolean
	return UserInputService:IsKeyDown(keyCode)
end

function input.queue_ref(): { InputObject }
	return queue
end

function input._insert_into_queue(input_object: InputObject, game_processed: boolean)
	if game_processed then
		return
	end

	table.insert(queue, input_object)
end

function input._map_input_symbol_to_action(symbol: symbolize_input.InputSymbol): AnyAction?
	return input_symbol_to_action[symbol]
end

function input._free_sink_thread(): thread?
	if not active_sink_thread then
		return
	end

	local threadRef = active_sink_thread
	active_sink_thread = nil

	return threadRef
end

function input.change_action_input(action: Action, newActionInput: symbolize_input.InputSymbol)
	local old_input_symbol = action.input
	input_symbol_to_action[old_input_symbol] = nil

	action.input = newActionInput
	input_symbol_to_action[newActionInput] = action :: AnyAction
end

local function create_action(
	action_kind: "held" | "long_press" | "tap",
	input_type: Enum.UserInputType,
	key_code: Enum.KeyCode
): AnyAction
	local input_symbol = symbolize_input.from_enum(input_type, key_code)
	if not input_symbol then
		return error(`failed to symbolize input {input_type} {key_code}`)
	end

	local action: AnyAction
	if action_kind == "held" then
		action = held_action(input_symbol)
	elseif action_kind == "long_press" then
		action = long_press_action(input_symbol)
	elseif action_kind == "tap" then
		action = tap_action(input_symbol)
	end

	input_symbol_to_action[input_symbol] = action :: AnyAction

	return action
end

input.create_action =
	create_action :: ((action_kind: "held", input_type: Enum.UserInputType, key_code: Enum.KeyCode?) -> HeldAction) & ((action_kind: "long_press", input_type: Enum.UserInputType, key_code: Enum.KeyCode?) -> long_pressAction) & ((action_kind: "tap", input_type: Enum.UserInputType, key_code: Enum.KeyCode?) -> TapAction)

function input.sink_next(): symbolize_input.InputSymbol
	active_sink_thread = coroutine.running()
	return coroutine.yield()
end

function input.read_mouse_delta() end

return input
