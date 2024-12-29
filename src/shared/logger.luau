--!optimize 1
local luauSignal = require("@pkg/signal")

export type LogLevel = "trace" | "log" | "warn" | "fatal" | "halt"

local signals = {
	trace = luauSignal(),
	log = luauSignal(),
	warn = luauSignal(),
	fatal = luauSignal(),
	halt = luauSignal(),
}

local function getNameFromStack()
	local name = debug.info(3, "s")
	local split = string.split(name, ".")

	return `{split[#split - 1]}/{split[#split]}`
end

local logger = {}
local metatable = { __index = logger }
export type Identity = typeof(setmetatable(
	{} :: {
		_name: string,
	},
	metatable
))

local function constructor(name: string?): Identity
	local self = setmetatable({}, metatable)

	self._name = name or getNameFromStack()

	return self
end

function logger.trace(self: Identity, text: string)
	signals.trace:fire(text, self._name)
end

function logger.log(self: Identity, text: string)
	signals.log:fire(text, self._name)
	print(`[{self._name}]: {text}`)
end

function logger.warn(self: Identity, text: string)
	signals.warn:fire(text, self._name)
	warn(`[{self._name}]: {text}`)
end

function logger.fatal(self: Identity, text: string): never
	signals.fatal:fire(text, self._name)
	return error(`[{self._name}]: {text}`)
end

-- this wont narrow types
function logger.assert(self: Identity, condition: boolean, text: string): ()
	if not condition then
		return self:fatal(text)
	end
end

function logger.halt(_self: Identity, text: string)
	signals.halt:fire(text)
end

return {
	new = constructor,

	on = function(level: LogLevel, callback: (text: string, source: string) -> ())
		signals[level]:connect(callback)
	end,
}
