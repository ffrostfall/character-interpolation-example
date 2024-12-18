local vide = require("@pkg/vide")

return function(props: {
	size: UDim2,
	position: UDim2,
	anchorPoint: Vector2?,

	color: Color3?,
	transparency: number?,

	children: { Instance },
})
	return vide.create("Frame")({
		Size = props.size,
		Position = props.position,
		AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),

		BackgroundTransparency = props.transparency or 1,
		BackgroundColor3 = props.color or Color3.new(),

		table.unpack(props.children),
	})
end
