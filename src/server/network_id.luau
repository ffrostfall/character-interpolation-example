local LIMIT = 32

local ids: { [number]: true? } = {}

local function free_id(identifier: number)
	ids[identifier] = nil
end

local function use_id(identifier: number)
	ids[identifier] = true
end

local function get_unused_id(): number
	for i = 1, LIMIT do
		if not ids[i] then
			return i
		end
	end

	return error("no available network ID")
end

local function get_id(): number
	local id = get_unused_id()
	use_id(id)

	return id
end

return {
	freeId = free_id,
	getId = get_id,
	useId = use_id,
}
