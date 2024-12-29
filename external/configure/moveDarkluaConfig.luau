local fs = require("@lune/fs")

return function()
	if fs.isFile("build/darklua.json") then
		fs.removeFile("build/darklua.json")
	end

	fs.copy("external/configs/darklua.json", "build/darklua.json", true)
end
