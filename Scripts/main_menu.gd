extends Control
# Called when the node enters the scene tree for the first time.
func _ready():
	%PlayButton.pressed.connect(play)

func play():
	get_tree().change_scene_to_file(
		"res://Scenes/game.tscn")

# Still need to add Settings Credits and Quit Functions.
