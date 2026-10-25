extends Control

# Main Containers
@onready var main_buttons: Control = %MainButtons
@onready var settings_menu: Control = %SettingsMenu
@onready var credits_menu: Control = %CreditsMenu

# Main Buttons
@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var quit_button: Button = %QuitButton

# Back Buttons
@onready var settings_back_button: Button = %SettingsBackButton
@onready var credits_back_button: Button = %CreditsBackButton

# Audio Controls
@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider

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
	# 1. Fetch Audio Bus Indices
	master_bus_idx = AudioServer.get_bus_index("Master")
	music_bus_idx = AudioServer.get_bus_index("Music")
	sfx_bus_idx = AudioServer.get_bus_index("SFX")
	
	# 2. Set default visibility
	_show_main_buttons()

	# 3. Connect Main Navigation Buttons safely
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if credits_button:
		credits_button.pressed.connect(_on_credits_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

	if settings_back_button:
		settings_back_button.pressed.connect(_show_main_buttons)
	if credits_back_button:
		credits_back_button.pressed.connect(_show_main_buttons)

	# 4. Connect Audio Sliders safely
	if master_slider:
		master_slider.value_changed.connect(_on_master_volume_changed)
	if music_slider:
		music_slider.value_changed.connect(_on_music_volume_changed)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)

	# 5. Setup & Connect Graphics Options safely
	if resolution_option:
		_setup_resolution_options()
		resolution_option.item_selected.connect(_on_resolution_selected)
	if window_mode_option:
		_setup_window_mode_options()
		window_mode_option.item_selected.connect(_on_window_mode_selected)

# --- Navigation ---

func _show_main_buttons() -> void:
	if main_buttons: main_buttons.show()
	if settings_menu: settings_menu.hide()
	if credits_menu: credits_menu.hide()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_settings_pressed() -> void:
	if main_buttons: main_buttons.hide()
	if settings_menu: settings_menu.show()

func _on_credits_pressed() -> void:
	if main_buttons: main_buttons.hide()
	if credits_menu: credits_menu.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

# --- Audio Settings ---

func _on_master_volume_changed(value: float) -> void:
	if master_bus_idx != -1:
		AudioServer.set_bus_volume_db(master_bus_idx, linear_to_db(value))

func _on_music_volume_changed(value: float) -> void:
	if music_bus_idx != -1:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(value))

func _on_sfx_volume_changed(value: float) -> void:
	if sfx_bus_idx != -1:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(value))

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
