local fs = require("@lune/fs")

local reconcileDirectories = {}

function reconcileDirectories.all()
	reconcileDirectories.blink()
	reconcileDirectories.game()
	reconcileDirectories.stories()
end

function reconcileDirectories.blink()
	if not fs.isDir("build") then
		fs.writeDir("build")
		fs.writeDir("build/net")
		return
	end

	if fs.isDir("build") and not fs.isDir("build/net") then
		fs.writeDir("build/net")
	end
end

function reconcileDirectories.game()
	fs.copy("src/", "build/game/", true)
end

function reconcileDirectories.stories()
	if fs.isDir("build") and fs.isDir("build/stories") then
		fs.removeDir("build/stories")

		fs.writeDir("build/stories")
	end
end

return reconcileDirectories
