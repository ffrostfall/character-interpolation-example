local frame = require("@shared/frame")
local frameNumber = require("@server/frameNumber")

return frame.on("gameTick", function()
	frameNumber.increment()
end)
