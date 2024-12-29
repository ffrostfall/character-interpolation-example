local input = require("@client/input")

return {
	FORWARD = input.createAction("held", Enum.UserInputType.Keyboard, Enum.KeyCode.W),
	BACKWARD = input.createAction("held", Enum.UserInputType.Keyboard, Enum.KeyCode.S),
	LEFT = input.createAction("held", Enum.UserInputType.Keyboard, Enum.KeyCode.A),
	RIGHT = input.createAction("held", Enum.UserInputType.Keyboard, Enum.KeyCode.D),

	DEBUGGER = input.createAction("tap", Enum.UserInputType.Keyboard, Enum.KeyCode.E),
}
