local fs = require("@lune/fs")
local process = require("@lune/process")

return function()
	fs.writeDir("build")
	fs.writeDir("build/game")
	fs.writeDir("build/stories")

	fs.writeDir("Packages")
	fs.writeDir("vendor")

	process.spawn("git", {
		"clone",
		"https://github.com/ffrostfall/lunePackages.git",
		"vendor/lunePackagesRepo",
	})

	if fs.isDir("vendor/lunePackages") then fs.removeDir("vendor/lunePackages") end
	fs.copy("vendor/lunePackagesRepo", "vendor/lunePackages")
	fs.removeDir("vendor/lunePackagesRepo")
end
