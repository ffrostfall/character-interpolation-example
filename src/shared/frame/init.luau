local RunService = game:GetService("RunService")

local phases = require("./phases")

local frame = {}

function frame.on(phaseName: phases.PhaseNames, callback: (deltaTime: number) -> ()): any
	local phaseObject = phases[phaseName]

	if RunService:IsServer() and phaseObject.context == "client" then
		return error("wrong context")
	elseif RunService:IsClient() and phaseObject.context == "server" then
		return error("wrong context")
	end

	phases.scheduler.systems.new(callback, phaseObject.entity)

	return true
end

return frame
