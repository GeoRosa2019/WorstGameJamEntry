extends Control

@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	# Ensure the pause menu starts hidden
	hide()
	
	# Connect button signals
	resume_button.pressed.connect(_unpause_game)
	quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	# Toggle pause state when pressing the Escape key action
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			_unpause_game()
		else:
			_pause_game()

func _pause_game() -> void:
	get_tree().paused = true
	show()

func _unpause_game() -> void:
	get_tree().paused = false
	hide()

func _on_quit_pressed() -> void:
	# Always unpause before quitting or changing scenes
	get_tree().paused = false
	get_tree().quit() # Or use: get_tree().change_scene_to_file("res://MainMenu.tscn")
