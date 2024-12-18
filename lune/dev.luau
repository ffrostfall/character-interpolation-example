local configure = require("@ext/configure")
local process = require("@lune/process")
local rojo = require("@vendor/lunePackages/rojo")
local task = require("@lune/task")
local watch = require("@vendor/lunePackages/watch")

process.env["target"] = "development"

if process.args[1] == "watch" then
	watch.directory({ "net" }, configure.blink)
	watch.directory({ "src" }, configure.game)
	watch.directory({ "stories" }, configure.stories)

	-- im lazy :(
	task.wait(2.5)

	rojo.serve("build/build.project.json")
else
	configure.all()

	rojo.serve("build/build.project.json")
end
