extends Control

# Pause Menu Navigation Containers
@onready var pause_buttons: Control = %PauseButtons
@onready var settings_menu: Control = %SettingsMenu

# Pause Buttons
@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var settings_back_button: Button = %SettingsBackButton

# Audio Controls
@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider

@onready var master_value_label: Label = %MasterValueLabel
@onready var music_value_label: Label = %MusicValueLabel
@onready var sfx_value_label: Label = %SFXValueLabel

# Graphics Controls
@onready var resolution_option: OptionButton = %ResolutionOption
@onready var window_mode_option: OptionButton = %WindowModeOption

# Audio Bus Indices
var master_bus_idx: int
var music_bus_idx: int
var sfx_bus_idx: int

# Resolution List
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]

func _ready() -> void:
	# Ensure the pause menu starts hidden and unpaused
	hide()
	
	# 1. Fetch Audio Bus Indices
	master_bus_idx = AudioServer.get_bus_index("Master")
	music_bus_idx = AudioServer.get_bus_index("Music")
	sfx_bus_idx = AudioServer.get_bus_index("SFX")

	# 2. Connect Pause Navigation Buttons safely
	if resume_button:
		resume_button.pressed.connect(_unpause_game)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if settings_back_button:
		settings_back_button.pressed.connect(_show_pause_buttons)

	# 3. Connect Audio Sliders safely
	if master_slider:
		master_slider.value_changed.connect(_on_master_volume_changed)
	if music_slider:
		music_slider.value_changed.connect(_on_music_volume_changed)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)

	# 4. Setup & Connect Graphics Options safely
	if resolution_option:
		_setup_resolution_options()
		resolution_option.item_selected.connect(_on_resolution_selected)
	if window_mode_option:
		_setup_window_mode_options()
		window_mode_option.item_selected.connect(_on_window_mode_selected)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			# If settings menu is open, pressing Escape returns to main pause menu first
			if settings_menu and settings_menu.visible:
				_show_pause_buttons()
			else:
				_unpause_game()
		else:
			_pause_game()

# --- Pause Navigation ---

func _pause_game() -> void:
	get_tree().paused = true
	show()
	_show_pause_buttons()

func _unpause_game() -> void:
	get_tree().paused = false
	hide()

func _show_pause_buttons() -> void:
	if pause_buttons: pause_buttons.show()
	if settings_menu: settings_menu.hide()

func _on_settings_pressed() -> void:
	if pause_buttons: pause_buttons.hide()
	if settings_menu: settings_menu.show()

func _on_quit_pressed() -> void:
	# Always unpause before quitting or changing scenes
	get_tree().paused = false
	get_tree().quit() # Or use: get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# --- Audio Settings ---

func _on_master_volume_changed(value: float) -> void:
	if master_bus_idx != -1:
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(value))
	if master_value_label:
		master_value_label.text = str(round(value * 100)) + "%"

func _on_music_volume_changed(value: float) -> void:
	if music_bus_idx != -1:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(value))
	if music_value_label:
		music_value_label.text = str(round(value * 100)) + "%"

func _on_sfx_volume_changed(value: float) -> void:
	if sfx_bus_idx != -1:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(value))
	if sfx_value_label:
		sfx_value_label.text = str(round(value * 100)) + "%"

# --- Graphics & Display Settings ---

func _setup_resolution_options() -> void:
	resolution_option.clear()
	for res in RESOLUTIONS:
		resolution_option.add_item(str(res.x) + " x " + str(res.y))
	resolution_option.select(2) # Default: 1920 x 1080

func _on_resolution_selected(index: int) -> void:
	var selected_res = RESOLUTIONS[index]
	DisplayServer.window_set_size(selected_res)

func _setup_window_mode_options() -> void:
	window_mode_option.clear()
	window_mode_option.add_item("Windowed")
	window_mode_option.add_item("Fullscreen")
	window_mode_option.add_item("Borderless Windowed")
	window_mode_option.select(0)

func _on_window_mode_selected(index: int) -> void:
	match index:
		0: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		2: # Borderless Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
