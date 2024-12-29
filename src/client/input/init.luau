local UserInputService = game:GetService("UserInputService")

local inputTypedef = require("@shared/typedefs/inputTypedef")
local logger = require("@shared/logger").new()
local luauSignal = require("@pkg/signal")
local symbolizeInput = require("./symbolizeInput")

type TapAction = Action & {
	tapped: luauSignal.Identity<()>,
	kind: "tap",
}
local function tapAction(defaultInputSymbol: inputTypedef.InputSymbol): TapAction
	return {
		tapped = luauSignal(),

		inputSymbol = defaultInputSymbol,
		kind = "tap" :: "tap",
	}
end

type LongPressAction = Action & {
	started: luauSignal.Identity<()>,
	ended: luauSignal.Identity<()>,
	cancelled: luauSignal.Identity<()>,

	kind: "longPress",
	_pressed: number,
}
local function longPressAction(defaultInputSymbol: inputTypedef.InputSymbol): LongPressAction
	return {
		started = luauSignal(),
		ended = luauSignal(),
		cancelled = luauSignal(),

		inputSymbol = defaultInputSymbol,
		kind = "longPress" :: "longPress",
		_pressed = 0,
	}
end

type HeldAction = Action & {
	beingHeld: boolean,

	kind: "held",
}
local function heldAction(defaultInputSymbol: inputTypedef.InputSymbol): HeldAction
	return {
		beingHeld = false,

		inputSymbol = defaultInputSymbol,
		kind = "held" :: "held",
	}
end

type Action = {
	inputSymbol: inputTypedef.InputSymbol,
}
type AnyAction = TapAction | LongPressAction | HeldAction

local activeSinkThread: thread?
local inputSymbolToAction: { [inputTypedef.InputSymbol]: AnyAction } = {}
local queue = {}

local input = {}

function input.init()
	UserInputService.InputBegan:Connect(input._insertIntoQueue)
	UserInputService.InputEnded:Connect(input._insertIntoQueue)
end

function input.isKeyDown(keyCode: Enum.KeyCode): boolean
	return UserInputService:IsKeyDown(keyCode)
end

function input.queueRef(): { InputObject }
	return queue
end

function input._insertIntoQueue(inputObject: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	table.insert(queue, inputObject)
end

function input._mapInputSymbolToAction(symbol: inputTypedef.InputSymbol): AnyAction?
	return inputSymbolToAction[symbol]
end

function input._freeSinkThread(): thread?
	if not activeSinkThread then
		return
	end

	local threadRef = activeSinkThread
	activeSinkThread = nil

	return threadRef
end

function input.changeActionInput(action: Action, newActionInput: inputTypedef.InputSymbol)
	local oldInputSymbol = action.inputSymbol
	inputSymbolToAction[oldInputSymbol] = nil

	action.inputSymbol = newActionInput
	inputSymbolToAction[newActionInput] = action :: AnyAction
end

local function createAction(
	actionKind: "held" | "longPress" | "tap",
	inputType: Enum.UserInputType,
	keyCode: Enum.KeyCode
): AnyAction
	local inputSymbol = symbolizeInput.fromEnums(inputType, keyCode)
	if not inputSymbol then
		return logger:fatal(`failed to symbolize input {inputType} {keyCode}`)
	end

	local action: AnyAction
	if actionKind == "held" then
		action = heldAction(inputSymbol)
	elseif actionKind == "longPress" then
		action = longPressAction(inputSymbol)
	elseif actionKind == "tap" then
		action = tapAction(inputSymbol)
	end

	inputSymbolToAction[inputSymbol] = action :: AnyAction

	return action
end

input.createAction =
	createAction :: ((actionKind: "held", inputType: Enum.UserInputType, keyCode: Enum.KeyCode?) -> HeldAction) & ((actionKind: "longPress", inputType: Enum.UserInputType, keyCode: Enum.KeyCode?) -> LongPressAction) & ((actionKind: "tap", inputType: Enum.UserInputType, keyCode: Enum.KeyCode?) -> TapAction)

function input.sinkNext(): inputTypedef.InputSymbol
	activeSinkThread = coroutine.running()
	return coroutine.yield()
end

return input
