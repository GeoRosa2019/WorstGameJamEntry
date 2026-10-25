extends TextureRect

@export var partName: String = ""
@export var correctPort: String = ""

signal partChange

var draggedTexture: Texture2D = null
var draggedName: String = ""

# Triggers when you click and drag
func _get_drag_data(at_position):
	if texture == null:
		return null
		
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.size = Vector2(30,30)
 
	var preview = Control.new()
	preview.add_child(preview_texture)
	set_drag_preview(preview)
	
	#Saved the Texture
	draggedTexture = texture
	draggedName = partName
	
	#Clear the node if no longer in use
	texture = null
	partName = ""
	modulate = Color.WHITE
 
	return {"texture": draggedTexture, "partName": draggedName, "source": self}
 
# Triggers when you hover with dragged item
func _can_drop_data(_pos, data):
	return data is Dictionary and data.has("partName")
 
# Triggers when you drop item
func _drop_data(_pos, data):
	
	if texture != null:
		data["source"].texture = texture
		data["source"].partName = partName
		
	texture = data["texture"]
	partName = data["partName"]
	partChange.emit()
	if data["source"] != self:
		data["source"].partChange.emit()
	
	# Adding color to signal whether spot is correct
	if correctPort != "":
		modulate = Color.GREEN if isCorrect() else Color.CRIMSON
#
func _notification(notify):
	if notify == NOTIFICATION_DRAG_END:
		if draggedTexture != null:
			if not get_viewport().gui_is_drag_successful():
				texture = draggedTexture
				partName = draggedName
			draggedTexture = null
			draggedName = ""
			
#Checker
func isCorrect() -> bool:
	return partName != "" and partName == correctPort
