local STDIO_FORWARD = { stdio = "forward" :: "forward" }

local process = require("@lune/process")
local task = require("@lune/task")

process.env["target"] = "development"

task.spawn(function()
	process.spawn("blink", { "net/main.blink", "--watch" }, STDIO_FORWARD)
end)

task.spawn(function()
	process.spawn("darklua", { "process", "src/", "build/", "--watch" }, STDIO_FORWARD)
end)

task.spawn(function()
	process.spawn("rojo", { "sourcemap", "--output", "sourcemap.json", "--include-non-scripts" }, STDIO_FORWARD)
end)

task.spawn(function()
	process.spawn("rojo", { "serve", "build.project.json" }, STDIO_FORWARD)
end)

-- scheduler spinning
while true do
	task.wait(1)
end
