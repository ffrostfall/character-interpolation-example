local input = require("@client/input")

return {
	FORWARD = input.create_action("held", Enum.UserInputType.Keyboard, Enum.KeyCode.W),
	BACKWARD = input.create_action("held", Enum.UserInputType.Keyboard, Enum.KeyCode.S),
	LEFT = input.create_action("held", Enum.UserInputType.Keyboard, Enum.KeyCode.A),
	RIGHT = input.create_action("held", Enum.UserInputType.Keyboard, Enum.KeyCode.D),

	DEBUGGER = input.create_action("tap", Enum.UserInputType.Keyboard, Enum.KeyCode.E),
}
