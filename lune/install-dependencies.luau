local STDIO_FORWARD = { stdio = "forward" :: "forward" }

local process = require("@lune/process")

process.spawn("wally", { "install" }, STDIO_FORWARD)

process.spawn("rojo", { "sourcemap", "--output", "sourcemap.json" }, STDIO_FORWARD)

process.spawn("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" }, STDIO_FORWARD)
