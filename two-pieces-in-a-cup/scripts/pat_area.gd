extends Area2D
signal petted
signal pet_stopped

@export var pat_cursor: Texture2D
@export var cursor_hotspot: Vector2 = Vector2.ZERO
@export var default_cursor: Texture2D
@export var default_cursor_hotspot: Vector2 = Vector2.ZERO

var dragging_over := false

func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(pat_cursor, Input.CURSOR_ARROW, cursor_hotspot)

func _on_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, default_cursor_hotspot)

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		if not dragging_over:
			dragging_over = true
			petted.emit()

func _process(_delta: float) -> void:
	if dragging_over and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragging_over = false
		pet_stopped.emit()
