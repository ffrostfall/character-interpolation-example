local async = require("@vendor/lunePackages/async")
local darklua = require("@vendor/lunePackages/darklua")
local reconcileDirectories = require("../reconcileDirectories")
local styles = require("../data/styles")

return function()
	print(styles.header("configure: darklua (game)"))
	reconcileDirectories.game()
	async(darklua.build("src/", "build/game", "build/darklua.json", false))
end
