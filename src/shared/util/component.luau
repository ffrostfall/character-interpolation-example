local jecs = require("@shared/jecs")
local world = require("@shared/world")

local function component_trait<T>(component: jecs.Entity<T>, value: T): (entity: jecs.Entity) -> ()
	return function(entity)
		world:set(entity, component, value)
	end
end

local function new(traits: { (entity: jecs.Entity) -> () }?): jecs.Entity
	local entity = world:component()

	if traits then
		for _, applied_trait in traits do
			applied_trait(entity)
		end
	end

	return entity
end

return {
	new = new,
	trait = component_trait,
}
