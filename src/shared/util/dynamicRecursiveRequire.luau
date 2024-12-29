local function recursiveRequire(instance: Instance)
	for _, v in instance:GetChildren() do
		if v.Name == "exclude_auto_require" then continue end
		recursiveRequire(v)
		if v:IsA("ModuleScript") then
			--print(`Client loading system {v.Name}`)
			local _ = require(v :: any) :: any
			continue
		end
	end
end

return recursiveRequire
