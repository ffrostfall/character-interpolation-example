local RunService = game:GetService("RunService")

local phases = require("./phases")

local frame = {}

function frame.on(phase_name: phases.PhaseNames, callback: (deltaTime: number) -> ()): any
	local phase_object = phases[phase_name]

	if RunService:IsServer() and phase_object.context == "client" then
		return error("wrong context")
	elseif RunService:IsClient() and phase_object.context == "server" then
		return error("wrong context")
	end

	phases.scheduler.systems.new(callback, phase_object.entity)

	return true
end

return frame
