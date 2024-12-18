local async = require("@vendor/lunePackages/async")
local darklua = require("@vendor/lunePackages/darklua")
local reconcileDirectories = require("../reconcileDirectories")
local styles = require("../data/styles")

return function()
	print(styles.header("configure: darklua (stories)"))
	reconcileDirectories.stories()
	async(darklua.build("stories/", "build/stories", "build/darklua.json", false))
end
