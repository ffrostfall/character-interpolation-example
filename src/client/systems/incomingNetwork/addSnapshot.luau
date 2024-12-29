local frame = require("@shared/frame")
local network = require("@network/client")
local interpolation = require("@shared/interpolation")

local latestReceived: number = 0

return frame.on("incomingNetwork", function()
	for _, snapshot in network.sendSnapshot.iter() do
		if snapshot.timestamp <= latestReceived then
			continue
		end

		latestReceived = math.max(snapshot.timestamp, latestReceived)

		snapshot.timestamp = os.clock()

		interpolation.addSnapshot(snapshot)
	end
end)
