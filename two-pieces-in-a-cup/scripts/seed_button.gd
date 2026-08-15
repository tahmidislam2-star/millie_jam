extends TextureButton

@export var plant_name: String = ""
@export var tree_texture: Texture2D
@export var starting_seeds: int = 5

@onready var amount_label: Label = $amount

var dragging := false
var drag_icon: TextureRect = null

func _ready() -> void:
	FarmStand.register_plant(plant_name, tree_texture, starting_seeds)
	FarmStand.seeds_changed.connect(_refresh)
	button_down.connect(_on_button_down)
	_refresh("")

func _refresh(_name: String) -> void:
	amount_label.text = str(FarmStand.get_seed_count(plant_name))
	disabled = not FarmStand.has_seed(plant_name)

func _on_button_down() -> void:
	if not FarmStand.has_seed(plant_name):
		return
	dragging = true
	drag_icon = TextureRect.new()
	drag_icon.texture = FarmStand.seed_icon_texture
	drag_icon.size = Vector2(48, 48)   
	drag_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().current_scene.add_child(drag_icon)

func _process(_delta: float) -> void:
	if not dragging:
		return
	var mouse_pos := WorldBounds.clamp_point(get_global_mouse_position())
	drag_icon.global_position = mouse_pos - drag_icon.size / 2.0
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_finish_drag(mouse_pos)

func _finish_drag(mouse_pos: Vector2) -> void:
	dragging = false
	for plot in get_tree().get_nodes_in_group("plots"):
		if plot.can_plant() and plot.get_global_rect().has_point(mouse_pos):
			plot.plant_seed(plant_name)
			FarmStand.use_seed(plant_name)
			break
	drag_icon.queue_free()
	drag_icon = null
