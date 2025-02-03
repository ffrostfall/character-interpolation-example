local jecs = require("@shared/jecs")
local shared_components = require("@shared/components")
local world = require("@shared/world")

local pendingCFrameUpdates = {
	parts = {} :: { BasePart },
	coordinate_frames = {} :: { CFrame },
}

local data_model = {}

function data_model.init()
	world:set(shared_components.Transform, jecs.OnSet, function(entity, value)
		local Model = world:get(entity, shared_components.Model)
		if not Model then
			return
		end

		data_model.defer_cframe_update(Model.primary_part, value)
	end)

	world:set(shared_components.Model, jecs.OnRemove, function(entity)
		local Model = world:get(entity, shared_components.Model)
		if not Model then
			return
		end

		if Model.inst.Parent ~= nil then
			Model.inst:Destroy()
		end
	end)
end

function data_model.defer_cframe_update(part: BasePart, coordinateFrame: CFrame)
	table.insert(pendingCFrameUpdates.parts, part)
	table.insert(pendingCFrameUpdates.coordinate_frames, coordinateFrame)
end

function data_model.bulk_update()
	debug.profilebegin("bulk updating cframes")

	workspace:BulkMoveTo(
		pendingCFrameUpdates.parts,
		pendingCFrameUpdates.coordinate_frames,
		Enum.BulkMoveMode.FireCFrameChanged
	)

	table.clear(pendingCFrameUpdates.parts)
	table.clear(pendingCFrameUpdates.coordinate_frames)
	debug.profileend()
end

function data_model.sync_from()
	debug.profilebegin("syncing dm to ecs")

	for entity, Model in world:query(shared_components.Model):with(shared_components.PhysicsTransform):iter() do
		world:set(entity, shared_components.PhysicsTransform, Model.primary_part.CFrame)
	end

	debug.profileend()
end

return data_model
