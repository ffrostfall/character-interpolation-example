local jecs = require("@shared/jecs")
local logger = require("@shared/logger").new()
local world = require("@shared/world")

return function(root: Folder | ModuleScript)
	local descendants = root:GetDescendants()
	if root:IsA("ModuleScript") then
		table.insert(descendants, root)
	end

	for _, inst in descendants do
		if inst:IsA("ModuleScript") then
			local componentDefinitions = require(inst) :: any

			for key, value in componentDefinitions do
				if typeof(value) ~= "number" then
					logger:warn(`Component {key} in {inst.Name} is not an entity`)
					continue
				end

				world:set(value :: jecs.Entity, jecs.Name, key)
			end
		end
	end
end
