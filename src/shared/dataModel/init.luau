local jecs = require("@shared/jecs")
local sharedComponents = require("@shared/components")
local world = require("@shared/world")

local pendingCFrameUpdates = {
	parts = {} :: { BasePart },
	coordinateFrames = {} :: { CFrame },
}

local dataModel = {}

function dataModel.init()
	world:set(sharedComponents.Transform, jecs.OnSet, function(entity, value)
		local Model = world:get(entity, sharedComponents.Model)
		if not Model then
			return
		end

		dataModel.deferCFrameUpdate(Model.primaryPart, value)
	end)

	world:set(sharedComponents.Model, jecs.OnRemove, function(entity)
		local Model = world:get(entity, sharedComponents.Model)
		if not Model then
			return
		end

		if Model.inst.Parent ~= nil then
			Model.inst:Destroy()
		end
	end)
end

function dataModel.deferCFrameUpdate(part: BasePart, coordinateFrame: CFrame)
	table.insert(pendingCFrameUpdates.parts, part)
	table.insert(pendingCFrameUpdates.coordinateFrames, coordinateFrame)
end

function dataModel.bulkUpdateCFrame()
	debug.profilebegin("bulk updating cframes")

	workspace:BulkMoveTo(
		pendingCFrameUpdates.parts,
		pendingCFrameUpdates.coordinateFrames,
		Enum.BulkMoveMode.FireCFrameChanged
	)

	table.clear(pendingCFrameUpdates.parts)
	table.clear(pendingCFrameUpdates.coordinateFrames)
	debug.profileend()
end

function dataModel.syncFrom()
	debug.profilebegin("syncing dm to ecs")

	for entity, Model in world:query(sharedComponents.Model):with(sharedComponents.PhysicsTransform):iter() do
		world:set(entity, sharedComponents.PhysicsTransform, Model.primaryPart.CFrame)
	end

	debug.profileend()
end

return dataModel
