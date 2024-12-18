local async = require("@vendor/lunePackages/async")
local moveProjectFiles = require("./configure/moveProjectFiles")
local process = require("@lune/process")
local sourcemap = require("./configure/sourcemap")
local spawnProcess = require("@vendor/lunePackages/spawnProcess")
local styles = require("./data/styles")

return function()
	print(styles.header("Installing Wally dependencies"))
	async(spawnProcess("wally", { "install" }))

	moveProjectFiles()
	sourcemap()

	print(styles.header("Exporting types"))
	process.spawn(
		"wally-package-types",
		{ "--sourcemap", "darklua-sourcemap.json", "../Packages" },
		{
			cwd = "build",
			stdio = "forward",
		}
	)
end
