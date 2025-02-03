local function require_descendants(inst: Instance)
	for _, module in inst:GetDescendants() do
		if not module:IsA("ModuleScript") then
			continue
		end

		(require)(module)
	end
end

return require_descendants
