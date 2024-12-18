local async = require("@vendor/lunePackages/async")
local fs = require("@lune/fs")
local spawnProcess = require("@vendor/lunePackages/spawnProcess")
local styles = require("../data/styles")

return function()
	print(styles.header("configure: rojo sourcemap"))

	async(spawnProcess("rojo", {
		"sourcemap",
		"build/default.project.json",
		"--output",
		"build/darklua-sourcemap.json",
	}))

	async(spawnProcess("rojo", {
		"sourcemap",
		"default.project.json",
		"--output",
		"build/lsp-sourcemap.json",
		"--include-non-scripts",
	}))

	fs.removeFile("default.project.json")
end
