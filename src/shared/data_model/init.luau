local jecs = require("@shared/jecs")
local shared_components = require("@shared/components")
local world = require("@shared/world")

local pending_updates = {
	parts = {} :: { BasePart },
	coordinate_frames = {} :: { CFrame },
}

local data_model = {}

function data_model.init()
	world:set(shared_components.Transform, jecs.OnSet, function(entity, value)
		local PrimaryPart = world:get(entity, shared_components.PrimaryPart)
		if not PrimaryPart then
			return
		end

		data_model.defer_coordinate_frame_update(PrimaryPart, value)
	end)

	world:set(shared_components.PrimaryPart, jecs.OnRemove, function(entity)
		local PrimaryPart = world:get(entity, shared_components.PrimaryPart)
		if not PrimaryPart then
			return
		end

		if PrimaryPart.Parent ~= nil then
			PrimaryPart:Destroy()
		end
	end)
end

function data_model.defer_coordinate_frame_update(part: BasePart, coordinateFrame: CFrame)
	table.insert(pending_updates.parts, part)
	table.insert(pending_updates.coordinate_frames, coordinateFrame)
end

function data_model.bulk_update()
	debug.profilebegin("bulk updating cframes")

	workspace:BulkMoveTo(pending_updates.parts, pending_updates.coordinate_frames, Enum.BulkMoveMode.FireCFrameChanged)

	table.clear(pending_updates.parts)
	table.clear(pending_updates.coordinate_frames)
	debug.profileend()
end

function data_model.sync_from()
	debug.profilebegin("syncing dm to ecs")

	for entity, PrimaryPart in world:query(shared_components.PrimaryPart):with(shared_components.Physics):iter() do
		world:set(entity, shared_components.Transform, PrimaryPart.CFrame)
	end

	debug.profileend()
end

return data_model
