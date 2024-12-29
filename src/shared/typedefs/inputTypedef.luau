export type InputSymbol = {
	kind: "key",
	value: Enum.KeyCode,
} | {
	kind: "lmb",
} | {
	kind: "rmb",
} | {
	kind: "mmb",
}
export type TapActionConfig = {
	kind: "tap",
	input: InputSymbol,
}

export type HoldActionConfig = {
	kind: "hold",
	input: InputSymbol,
	holdDuration: number,
}

type RegisterActionFunction = (config: TapActionConfig) -> () | (config: HoldActionConfig) -> ()

return nil
