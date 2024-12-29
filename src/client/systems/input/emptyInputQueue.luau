local frame = require("@shared/frame")
local input = require("@client/input")
local symbolizeInput = require("@client/input/symbolizeInput")

local queueRef = input.queueRef()

local function handleInputObject(inputObject: InputObject)
	local inputSymbol = symbolizeInput.fromInputObject(inputObject)
	if not inputSymbol then
		return
	end

	local activeSinkThread = input._freeSinkThread()
	if activeSinkThread then
		task.spawn(activeSinkThread, inputSymbol)
		activeSinkThread = nil
		return
	end

	local relevantAction = input._mapInputSymbolToAction(inputSymbol)
	if not relevantAction then
		return
	end

	if inputObject.UserInputState == Enum.UserInputState.Begin then
		if relevantAction.kind == "tap" then
			relevantAction.tapped:fire()
		elseif relevantAction.kind == "longPress" then
			relevantAction._pressed = tick()
			relevantAction.started:fire()
		elseif relevantAction.kind == "held" then
			relevantAction.beingHeld = true
		end
	elseif inputObject.UserInputState == Enum.UserInputState.End then
		if relevantAction.kind == "longPress" then
			relevantAction.ended:fire()
		elseif relevantAction.kind == "held" then
			relevantAction.beingHeld = false
		end
	end
end

return frame.on("input", function()
	for index = #queueRef, 1, -1 do
		local inputObject = queueRef[index]

		handleInputObject(inputObject)

		table.remove(queueRef, index)
	end
end)
