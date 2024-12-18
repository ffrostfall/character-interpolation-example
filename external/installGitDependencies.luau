local async = require("@vendor/lunePackages/async")
local fs = require("@lune/fs")
local spawnProcess = require("@vendor/lunePackages/spawnProcess")
local styles = require("./data/styles")
local task = require("@lune/task")

return function()
	print(styles.header("Cloning git repositories"))
	async(spawnProcess("git", {
		"clone",
		"https://github.com/ffrostfall/lunePackages.git",
		"vendor/lunePackagesRepo",
	}))
	async(spawnProcess("git", {
		"clone",
		"https://github.com/decaying-winter/dwMapFormat.git",
		"vendor/dwMapFormatRepo",
	}))

	task.wait(0.5)

	print(styles.header("Processing git repositories, converting requires"))
	async(spawnProcess("darklua", {
		"process",
		"vendor/dwMapFormatRepo/src",
		"vendor/dwMapFormat",
		"--config",
		"vendor/dwMapFormatRepo/.darklua.json",
	}))

	task.wait(0.5)

	print(styles.header("Copying repositories to vendor"))
	if fs.isDir("vendor/lunePackages") then fs.removeDir("vendor/lunePackages") end
	fs.copy("vendor/lunePackagesRepo", "vendor/lunePackages")

	fs.removeDir("vendor/lunePackagesRepo")
	fs.removeDir("vendor/dwMapFormatRepo")
end
