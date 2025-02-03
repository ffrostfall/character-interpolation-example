local frame = require("@shared/frame")
local network = require("@net/client")
local interpolation = require("@shared/interpolation")

return frame.on("incoming_net", function()
	for _, snapshot in network.send_snapshot.iter() do
		interpolation.add_snapshot(snapshot)
	end
end)
