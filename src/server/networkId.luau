local LIMIT = 32

local ids: { [number]: true? } = {}

local function freeId(identifier: number)
	ids[identifier] = nil
end

local function useId(identifier: number)
	ids[identifier] = true
end

local function getUnusedId(): number
	for i = 1, LIMIT do
		if not ids[i] then
			return i
		end
	end

	return error("no available network ID")
end

local function getId(): number
	local id = getUnusedId()
	useId(id)

	return id
end

return {
	freeId = freeId,
	getId = getId,
	useId = useId,
}
