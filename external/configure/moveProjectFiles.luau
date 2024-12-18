local fs = require("@lune/fs")
local serde = require("@lune/serde")

local function recursiveDescent(dictionary: { [string]: any })
	for key, value in dictionary do
		if typeof(value) == "table" then recursiveDescent(value) end

		if key == "$path" then dictionary[key] = "../" .. value end
	end
end

return function()
	if not fs.isDir("build") then fs.writeDir("build") end

	pcall(fs.copy, "external/configs/build.project.json", "build/build.project.json")
	pcall(fs.copy, "external/configs/default.project.json", "default.project.json")
	pcall(fs.copy, "external/configs/default.project.json", "build/default.project.json")

	local contents = fs.readFile("external/configs/default.project.json")
	local decoded = serde.decode("json", contents)
	recursiveDescent(decoded)

	fs.writeFile("build/default.project.json", serde.encode("json", decoded))
end
