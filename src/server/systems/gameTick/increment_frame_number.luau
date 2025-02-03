local frame = require("@shared/frame")
local frameNumber = require("@server/frame_number")

return frame.on("game_tick", frameNumber.increment)
