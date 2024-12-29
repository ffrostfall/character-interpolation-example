local inputTypedef = require("@shared/typedefs/inputTypedef")

local keycodeSymbols: { [Enum.KeyCode]: inputTypedef.InputSymbol } = {}

local inputSymbols = {}

inputSymbols.lmb = {
	kind = "lmb" :: "lmb",
}

inputSymbols.rmb = {
	kind = "rmb" :: "rmb",
}

inputSymbols.mmb = {
	kind = "mmb" :: "mmb",
}

local function symbolizeEnums(userInputType: Enum.UserInputType, keyCode: Enum.KeyCode?): inputTypedef.InputSymbol?
	if userInputType == Enum.UserInputType.MouseButton1 then
		return inputSymbols.lmb
	elseif userInputType == Enum.UserInputType.MouseButton2 then
		return inputSymbols.rmb
	elseif userInputType == Enum.UserInputType.MouseButton3 then
		return inputSymbols.mmb
	elseif userInputType == Enum.UserInputType.Keyboard and keyCode then
		local existing = keycodeSymbols[keyCode]
		if existing then
			return existing
		end

		local new = {
			kind = "key" :: "key",
			value = keyCode,
		}
		keycodeSymbols[keyCode] = new
		return keycodeSymbols[keyCode]
	end

	return nil
end

local function symbolizeInputObject(inputObject: InputObject): inputTypedef.InputSymbol?
	return symbolizeEnums(inputObject.UserInputType, inputObject.KeyCode)
end

local symbolizeInput = {}

symbolizeInput.fromInputObject = symbolizeInputObject
symbolizeInput.fromEnums = symbolizeEnums

return symbolizeInput
