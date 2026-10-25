extends TextureRect

@export var toolName: String = ""  

func _get_drag_data(_pos):
	var previewTexture = TextureRect.new()
	previewTexture.texture = texture
	previewTexture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	previewTexture.size = Vector2(30, 30)

	var preview = Control.new()
	preview.add_child(previewTexture)
	set_drag_preview(preview)

	# Nothing is cleared here, so the tool stays in the tray and can be reused
	return {"type": "tool", "toolName": toolName}
