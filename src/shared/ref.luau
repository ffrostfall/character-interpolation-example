local RunService = game:GetService("RunService")

local jecs = require("@shared/jecs")
local world = require("@shared/world")

local runningOn: "server" | "client" = (if RunService:IsServer() then "server" else "client")
local localPlayerEntity = world:entity()
local localCharacterEntity: jecs.Entity? = nil
local playerRefs: { [string]: jecs.Entity } = {}
local networkIdRefs: { [number]: jecs.Entity } = {}
local currentRun: jecs.Entity? = nil
local gameGlobal: jecs.Entity? = nil

export type DefineFunction =
	((type: "localCharacter", entity: jecs.Entity) -> ())
	& ((type: "networkId", id: number, entity: jecs.Entity) -> ())
	& ((type: "player", robloxPlayer: Player, entity: jecs.Entity) -> ())
	& ((type: "currentRun", entity: jecs.Entity) -> ())
	& ((type: "game", entity: jecs.Entity) -> ())

export type GetFunction =
	((type: "localPlayer") -> jecs.Entity)
	& ((type: "localCharacter") -> jecs.Entity?)
	& ((type: "networkId", id: number) -> jecs.Entity?)
	& ((type: "player", robloxPlayer: Player) -> jecs.Entity?)
	& ((type: "currentRun") -> jecs.Entity?)
	& ((type: "game") -> jecs.Entity?)

export type DeleteFunction =
	((type: "localCharacter") -> ())
	& ((type: "networkId", id: number) -> ())
	& ((type: "player", robloxPlayer: Player) -> ())
	& ((type: "currentRun") -> ())

local ref = {}

ref.get = (
	function(type, data: any)
		if type == "localPlayer" then
			return localPlayerEntity
		elseif type == "localCharacter" then
			assert(runningOn == "client", "Cannot get localCharacter on server")

			return localCharacterEntity :: any
		elseif type == "networkId" then
			return networkIdRefs[data]
		elseif type == "player" then
			return playerRefs[tostring(data.UserId)]
		elseif type == "currentRun" then
			return currentRun :: jecs.Entity
		elseif type == "game" then
			return gameGlobal :: jecs.Entity
		end

		return error("unreachable")
	end
) :: GetFunction

ref.define = (
	function(type: string, data: any, entity: jecs.Entity)
		if type == "localCharacter" then
			assert(runningOn == "client", "Cannot define localCharacter on server")

			localCharacterEntity = data
		elseif type == "networkId" then
			networkIdRefs[data] = entity
		elseif type == "player" then
			playerRefs[tostring(data.UserId)] = entity
		elseif type == "currentRun" then
			currentRun = data
		elseif type == "game" then
			gameGlobal = data
		end
	end :: any
) :: DefineFunction

--[=[
	deletes the entity and deletes the reference
]=]
ref.delete = (
	function(type: string, data: any)
		if type == "localCharacter" then
			assert(runningOn == "client", "Cannot delete localCharacter on server")

			if localCharacterEntity then
				world:delete(localCharacterEntity)
				localCharacterEntity = nil
			end
		elseif type == "networkId" and networkIdRefs[data] then
			world:delete(networkIdRefs[data])
			networkIdRefs[data] = nil
		elseif type == "player" and playerRefs[tostring(data.UserId)] then
			world:delete(playerRefs[tostring(data.UserId)])
			playerRefs[tostring(data.UserId)] = nil
		elseif type == "currentRun" then
			if currentRun then
				world:delete(currentRun)
				currentRun = nil
			end
		end
	end :: any
) :: DeleteFunction

ref.untrack = (
	function(type: string, data: any)
		if type == "localCharacter" then
			assert(runningOn == "client", "Cannot delete localCharacter on server")

			if localCharacterEntity then localCharacterEntity = nil end
		elseif type == "networkId" and networkIdRefs[data] then
			networkIdRefs[data] = nil
		elseif type == "player" and playerRefs[tostring(data.UserId)] then
			playerRefs[tostring(data.UserId)] = nil
		elseif type == "currentRun" then
			if currentRun then currentRun = nil end
		end
	end :: any
) :: DeleteFunction

return ref
