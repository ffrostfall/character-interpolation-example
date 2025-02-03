--!native
local SNAPSHOT_HISTORY_LENGTH = 32
local TAU = math.pi * 2

local network_types = require("@net/types")

local snapshot_timeline: { [number]: network_types.Snapshot } = {}

local function find_snapshot_before(timestamp: number): network_types.Snapshot?
	-- we can assume that order of timestamps is guranteed, iterate backwards
	for i = SNAPSHOT_HISTORY_LENGTH, 1, -1 do
		local currentFrame = snapshot_timeline[i]
		if not currentFrame then
			continue
		end

		if currentFrame.timestamp <= timestamp then
			return currentFrame
		end
	end

	return
end

local function find_snapshot_after(timestamp: number): network_types.Snapshot?
	for i = 1, SNAPSHOT_HISTORY_LENGTH do
		local currentFrame = snapshot_timeline[i]
		if not currentFrame then
			break
		end

		if currentFrame.timestamp >= timestamp then
			return currentFrame
		end
	end

	return nil
end

local function absolute_angle(angle: number): number
	return angle % TAU
end

local function find_shortest_angle(angle0: number, angle1: number): number
	local diff1 = absolute_angle(angle1 - angle0)
	local diff2 = absolute_angle(angle0 - angle1)

	return if diff1 < diff2 then diff1 else -diff2
end

local function lerp_angle(angle0: number, angle1: number, t: number): number
	local diff = find_shortest_angle(angle0, angle1)

	return angle0 + (diff * t)
end

local function lerp_vector(a: vector, b: vector, t: number): vector
	return a + (b - a) * t
end

local interpolation = {}

function interpolation.add_snapshot(snapshot: network_types.Snapshot)
	table.insert(snapshot_timeline, snapshot)

	if #snapshot_timeline > SNAPSHOT_HISTORY_LENGTH then
		table.remove(snapshot_timeline, 1)
	end
end

function interpolation.at(render_timestamp: number): { [number]: CFrame }?
	local before = find_snapshot_before(render_timestamp)
	local after = find_snapshot_after(render_timestamp)

	if before == nil or after == nil then
		return
	end

	local result = {}

	for network_id, transform in before.transforms do
		local after_transform = after.transforms[network_id]
		if not after_transform then
			continue
		end

		local start_time = before.timestamp
		local end_time = after.timestamp

		local snapshot_delta_time = end_time - start_time
		local time_since_first_snapshot = render_timestamp - start_time

		local alpha = time_since_first_snapshot / snapshot_delta_time
		local position = lerp_vector(transform.position, after_transform.position, alpha)
		local rotation = lerp_angle(transform.y_rot, after_transform.y_rot, alpha)
		local sin, cos = math.sin(rotation), math.cos(rotation)

		--stylua: ignore
		result[network_id] = CFrame.new(
			position.X, position.Y, position.Z,
			cos, 0, sin,
			0, 1, 0,
			-sin, 0, cos
		)
		--stylua: endignore
	end

	return result
end

return interpolation
