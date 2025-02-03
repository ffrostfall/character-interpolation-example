export type InputSymbol = {
	kind: "key",
	value: Enum.KeyCode,
} | {
	kind: "lmb",
} | {
	kind: "rmb",
} | {
	kind: "mmb",
}

local keycode_symbols: { [Enum.KeyCode]: InputSymbol } = {}
local mouse_symbols = {}

mouse_symbols.lmb = {
	kind = "lmb" :: "lmb",
}

mouse_symbols.rmb = {
	kind = "rmb" :: "rmb",
}

mouse_symbols.mmb = {
	kind = "mmb" :: "mmb",
}

local function symbolize_enum(input_type: Enum.UserInputType, keycode: Enum.KeyCode?): InputSymbol?
	if input_type == Enum.UserInputType.MouseButton1 then
		return mouse_symbols.lmb
	elseif input_type == Enum.UserInputType.MouseButton2 then
		return mouse_symbols.rmb
	elseif input_type == Enum.UserInputType.MouseButton3 then
		return mouse_symbols.mmb
	elseif input_type == Enum.UserInputType.Keyboard and keycode then
		local existing = keycode_symbols[keycode]
		if existing then
			return existing
		end

		local new = {
			kind = "key" :: "key",
			value = keycode,
		}
		keycode_symbols[keycode] = new
		return keycode_symbols[keycode]
	end

	return nil
end

local function symbolize_input_object(object: InputObject): InputSymbol?
	return symbolize_enum(object.UserInputType, object.KeyCode)
end

local symbolize_input = {}

symbolize_input.from_input_object = symbolize_input_object
symbolize_input.from_enum = symbolize_enum

return symbolize_input
