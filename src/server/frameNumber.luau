local frameNumber = {
	counter = 0,
}

function frameNumber.increment()
	frameNumber.counter += 1
end

return frameNumber
