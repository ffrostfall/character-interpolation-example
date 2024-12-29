--!native
local SNAPSHOT_HISTORY_LENGTH = 32
local TAU = math.pi * 2

local networkTypes = require("@network/types")

local snapshotTimeline: { [number]: networkTypes.Snapshot } = {}

local function findSnapshotBeforeTime(timestamp: number): networkTypes.Snapshot?
	-- we can assume that order of timestamps is guranteed, iterate backwards
	for i = SNAPSHOT_HISTORY_LENGTH, 1, -1 do
		local currentFrame = snapshotTimeline[i]
		if not currentFrame then
			continue
		end

		if currentFrame.timestamp <= timestamp then
			return currentFrame
		end
	end

	return
end

local function findSnapshotAfterTime(timestamp: number): networkTypes.Snapshot?
	for i = 1, SNAPSHOT_HISTORY_LENGTH do
		local currentFrame = snapshotTimeline[i]
		if not currentFrame then
			break
		end

		if currentFrame.timestamp >= timestamp then
			return currentFrame
		end
	end

	return nil
end

local function absoluteAngle(angle: number): number
	return angle % TAU
end

local function findShortestAngle(angle0: number, angle1: number): number
	local diff1 = absoluteAngle(angle1 - angle0)
	local diff2 = absoluteAngle(angle0 - angle1)

	return diff1 < diff2 and diff1 or -diff2
end

local function lerpAngle(angle0: number, angle1: number, t: number): number
	local diff = findShortestAngle(angle0, angle1)

	return angle0 + diff * t
end

local function lerpVector(a: vector, b: vector, t: number): vector
	return a + (b - a) * t
end

local interpolation = {}

function interpolation.addSnapshot(snapshot: networkTypes.Snapshot)
	table.insert(snapshotTimeline, snapshot)

	if #snapshotTimeline > SNAPSHOT_HISTORY_LENGTH then
		table.remove(snapshotTimeline, 1)
	end
end

function interpolation.at(renderTimestamp: number): { [number]: CFrame }?
	local before = findSnapshotBeforeTime(renderTimestamp)
	local after = findSnapshotAfterTime(renderTimestamp)

	if before == nil or after == nil then
		return
	end

	local result = {}

	for networkId, transform in before.transforms do
		local afterTransform = after.transforms[networkId]
		if not afterTransform then
			continue
		end

		local startTime = before.timestamp
		local endTime = after.timestamp

		local snapshotDeltaTime = endTime - startTime
		local timeSinceFirstSnapshot = renderTimestamp - startTime
		print(snapshotDeltaTime, timeSinceFirstSnapshot, startTime, endTime, renderTimestamp)

		local alpha = timeSinceFirstSnapshot / snapshotDeltaTime
		local position = lerpVector(transform.position, afterTransform.position, alpha)
		local rotation = lerpAngle(transform.yRotation, afterTransform.yRotation, alpha)
		local sin, cos = math.sin(rotation), math.cos(rotation)
		print(alpha)

		--stylua: ignore
		result[networkId] = CFrame.new(
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
