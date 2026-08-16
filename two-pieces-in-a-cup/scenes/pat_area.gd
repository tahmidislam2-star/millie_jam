extends Area2D

signal petted
signal pet_stopped

var dragging_over := false

func _ready() -> void:
	input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		if not dragging_over:
			dragging_over = true
			petted.emit()

func _process(_delta: float) -> void:
	if dragging_over and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragging_over = false
		pet_stopped.emit()
