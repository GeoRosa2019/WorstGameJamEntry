extends TextureRect

@export var partName: String = ""
@export var correctPort: String = ""
@export var requiredTools: Array[String] = []   

signal partChange
signal partPlaced(isRight: bool)
signal toolUsed(isRight: bool)

var appliedTools: Array[String] = []            #tools used on this slot so far
var draggedTexture: Texture2D = null
var draggedName: String = ""
var draggedTools: Array[String] = []            # remembered in case the drop fails
var startTexture: Texture2D
var startName: String

func _ready():
	startTexture = texture
	startName = partName

func resetToStart():
	texture = startTexture
	partName = startName
	appliedTools.clear()
	updateColor()

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

	draggedTexture = texture
	draggedName = partName
	draggedTools = appliedTools.duplicate()     

	#Clear the node if no longer in use
	texture = null
	partName = ""
	appliedTools.clear()                         
	updateColor()                                

	return {
		"type": "part",                          
		"texture": draggedTexture,
		"partName": draggedName,
		"appliedTools": draggedTools,            
		"source": self
	}

# Remember to fix bug with the slots
func _can_drop_data(_pos, data):
	if not (data is Dictionary and data.has("type")):
		return false

	if data["type"] == "tool":
		# tools only work on motherboard slots that currently hold a part
		return correctPort != "" and partName != ""

	return data["type"] == "part"

func _drop_data(_pos, data):
	if data["type"] == "tool":
		useTool(data["toolName"])
		return

	if texture != null:
		data["source"].texture = texture
		data["source"].partName = partName
		data["source"].appliedTools = appliedTools.duplicate()   
		data["source"].updateColor()                            

	texture = data["texture"]
	partName = data["partName"]
	appliedTools = data["appliedTools"].duplicate()           

	updateColor()
	if correctPort != "":   # motherboard slots only
		partPlaced.emit(partName == correctPort)
	partChange.emit()
	if data["source"] != self:
		data["source"].partChange.emit()


func useTool(toolName: String):
	if toolName in requiredTools and partName == correctPort:
		if toolName not in appliedTools:
			appliedTools.append(toolName)
		toolUsed.emit(true)
	else:
		toolUsed.emit(false)
		flashWrong()
	updateColor()
	partChange.emit()

func _notification(notify):
	if notify == NOTIFICATION_DRAG_END:
		if draggedTexture != null:
			if not get_viewport().gui_is_drag_successful():
				texture = draggedTexture
				partName = draggedName
				appliedTools = draggedTools.duplicate()          
				updateColor()                                    
			draggedTexture = null
			draggedName = ""
			draggedTools.clear()                               

#Checker
func isCorrect() -> bool:
	if partName == "" or partName != correctPort:
		return false
	for t in requiredTools:   
		if t not in appliedTools:                                   
			return false
	return true


func updateColor():
	if correctPort == "":
		return   # tray spot, no coloring
	if partName == "":
		modulate = Color.WHITE
	elif isCorrect():
		modulate = Color.GREEN
	elif partName == correctPort:
		modulate = Color.YELLOW     
	else:
		modulate = Color.CRIMSON     

# Quick red flash for a wrong tool
func flashWrong():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.CRIMSON, 0.1)
	tween.tween_property(self, "modulate", Color.YELLOW if partName == correctPort else Color.CRIMSON, 0.2)
