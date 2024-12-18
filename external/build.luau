local async = require("@vendor/lunePackages/async")
local configure = require("./configure")
local fs = require("@lune/fs")
local installGitDependencies = require("./installGitDependencies")
local installWallyDependencies = require("./installWallyDependencies")
local reconcileDirectories = require("./reconcileDirectories")
local roblox = require("@lune/roblox")
local rojo = require("@vendor/lunePackages/rojo")

return function()
	reconcileDirectories.all()

	installGitDependencies()
	installWallyDependencies()

	configure.all()

	async(rojo.build("build/build.project.json", "build/main.rbxl"))
	local main = fs.readFile("build/main.rbxl")
	local mainDataModel = roblox.deserializePlace(main)

	fs.writeFile("build/main.rbxl", roblox.serializePlace(mainDataModel, false))
end
