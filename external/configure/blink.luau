local async = require("@vendor/lunePackages/async")
local reconcileDirectories = require("../reconcileDirectories")
local spawnProcess = require("@vendor/lunePackages/spawnProcess")
local styles = require("../data/styles")

return function()
	print(styles.header("configure: blink"))
	reconcileDirectories.blink()

	async(spawnProcess("blink", { "net/main.blink" }))
end
