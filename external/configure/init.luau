--[[
	named "configure" after the traditional "configure" step in C projects.
]]

local blink = require("./blink")
local game = require("./game")
local moveDarkluaConfig = require("./moveDarkluaConfig")
local moveProjectFiles = require("./moveProjectFiles")
local reconcileDirectories = require("../reconcileDirectories")
local sourcemap = require("./sourcemap")

local configure = {}

function configure.all()
	reconcileDirectories.all()

	blink()

	moveProjectFiles()
	moveDarkluaConfig()

	sourcemap()

	game()
end

function configure.blink()
	blink()
end

function configure.stories()
	moveProjectFiles()
	moveDarkluaConfig()
	sourcemap()

	stories()
end

function configure.game()
	moveProjectFiles()
	moveDarkluaConfig()
	sourcemap()

	game()
end

return configure
