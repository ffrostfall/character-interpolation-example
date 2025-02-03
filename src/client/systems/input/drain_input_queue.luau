local frame = require("@shared/frame")
local input = require("@client/input")
local symbolize_input = require("@client/input/symbolize_input")

local queue_ref = input.queue_ref()

local function process_input_object(input_object: InputObject)
	local input_symbol = symbolize_input.from_input_object(input_object)
	if not input_symbol then
		return
	end

	local active_sink_thread = input._free_sink_thread()
	if active_sink_thread then
		task.spawn(active_sink_thread, input_symbol)
		active_sink_thread = nil
		return
	end

	local relevant_action = input._map_input_symbol_to_action(input_symbol)
	if not relevant_action then
		return
	end

	if input_object.UserInputState == Enum.UserInputState.Begin then
		if relevant_action.kind == "tap" then
			relevant_action.tapped:fire()
		elseif relevant_action.kind == "long_press" then
			relevant_action._pressed = tick()
			relevant_action.started:fire()
		elseif relevant_action.kind == "held" then
			relevant_action.being_held = true
		end
	elseif input_object.UserInputState == Enum.UserInputState.End then
		if relevant_action.kind == "long_press" then
			relevant_action.ended:fire()
		elseif relevant_action.kind == "held" then
			relevant_action.being_held = false
		end
	end
end

return frame.on("input", function()
	for index = #queue_ref, 1, -1 do
		local input_object = queue_ref[index]

		process_input_object(input_object)

		table.remove(queue_ref, index)
	end
end)
