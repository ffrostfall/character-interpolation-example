local UserInputService = game:GetService("UserInputService")

local accumulated_delta: vector = vector.zero

local mouse = {}

function mouse.init()
	UserInputService.InputChanged:Connect(mouse._input_changed)
end

function mouse._input_changed(input_object: InputObject, gameProcessedEvent: boolean)
	if not gameProcessedEvent then
		return
	end

	if input_object.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	local delta = input_object.Delta
	accumulated_delta += delta
end

function mouse.read_delta(): vector
	local delta = accumulated_delta
	accumulated_delta = vector.zero

	return delta
end

return mouse
