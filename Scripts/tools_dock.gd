extends Control
class_name ToolsDock

@onready var dock_container: VBoxContainer = %DockContainer
@onready var tab_header: PanelContainer = %TabHeader
@onready var content_panel: PanelContainer = %ContentPanel

@export var slide_duration: float = 0.25
@export var close_delay: float = 0.5

var open_y: float = 0.0
var closed_y: float = 0.0
var tween: Tween
var is_open: bool = false
var is_closing: bool = false

func _ready() -> void:
	await get_tree().process_frame
	_calculate_positions()
	dock_container.position.y = closed_y

func _calculate_positions() -> void:
	open_y = -dock_container.size.y
	closed_y = -tab_header.size.y

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var is_hovering = dock_container.get_global_rect().has_point(mouse_pos)

	if is_hovering:
		if not is_open or is_closing:
			slide_open()
	else:
		if is_open and not is_closing:
			slide_closed(close_delay)

func slide_open() -> void:
	is_open = true
	is_closing = false
	_animate_y(open_y, 0.0)

func slide_closed(delay: float = close_delay) -> void:
	is_closing = true
	_animate_y(closed_y, delay)

func force_close(instant: bool = false) -> void:
	var delay_time = 0.0 if instant else close_delay
	is_closing = true
	_animate_y(closed_y, delay_time)

func select_tool(tool_name: String) -> void:
	# Closes instantly when a tool icon is selected
	force_close(true)

func _animate_y(target_y: float, delay: float = 0.0) -> void:
	if tween and tween.is_running():
		tween.kill()
		
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if delay > 0.0:
		tween.tween_interval(delay)
		
	tween.tween_property(dock_container, "position:y", target_y, slide_duration)
	
	if target_y == closed_y:
		tween.tween_callback(func():
			is_open = false
			is_closing = false
		)
