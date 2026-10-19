extends Control

@onready var note_icon_button: Button = %NoteIconButton
@onready var note_popup: PanelContainer = %NotePopup
@onready var close_button: Button = %CloseButton
@onready var close_dialog_button: Button = %CloseDialogButton

func _ready() -> void:
	# Ensure correct initial visibility
	note_popup.hide()
	note_icon_button.show()
	
	# Connect signals via script
	note_icon_button.pressed.connect(_open_notes)
	close_button.pressed.connect(_close_notes)
	close_dialog_button.pressed.connect(_close_notes)

func _open_notes() -> void:
	note_icon_button.hide()
	note_popup.show() # Show first so Godot calculates the actual window size
	
	# Recalculate pivot point to the true center of the popup window
	note_popup.pivot_offset = note_popup.size / 2
	note_popup.scale = Vector2.ZERO
	
	# Pop-open animation
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(note_popup, "scale", Vector2.ONE, 0.25)

func _close_notes() -> void:
	# Shrink-close animation
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(note_popup, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(func():
		note_popup.hide()
		note_icon_button.show()
		);
