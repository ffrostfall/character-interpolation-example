local jecs = require("@shared/jecs")
local world = require("@shared/world")

local function componentTrait<T>(component: jecs.Entity<T>, value: T): (entity: jecs.Entity) -> ()
	return function(entity)
		world:set(entity, component, value)
	end
end

local function new(traits: { (entity: jecs.Entity) -> () }?): jecs.Entity
	local entity = world:component()

	if traits then
		for _, appliedTrait in traits do
			appliedTrait(entity)
		end
	end

	return entity
end

return {
	new = new,
	trait = componentTrait,
}
