extends Control
signal harvested(plant_name: String)
enum State { EMPTY, SEEDED, WATERED, GROWN }
@onready var plant: TextureRect = $plant
@onready var seeded: TextureRect = $seeded
@onready var watered: TextureRect = $watered
var state: State = State.EMPTY
var plant_type: String = ""
var border: TextureRect

func _ready() -> void:
	add_to_group("plots")
	plant.visible = false
	seeded.visible = false
	watered.visible = false
	plant.mouse_filter = Control.MOUSE_FILTER_STOP
	plant.gui_input.connect(_on_plant_gui_input)
	plant.mouse_entered.connect(_on_plant_mouse_entered)
	plant.mouse_exited.connect(_on_plant_mouse_exited)

	border = TextureRect.new()
	border.material = _make_outline_material()
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.visible = false
	add_child(border)

func _make_outline_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform float outline_width : hint_range(0.0, 5.0) = 1.5;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * outline_width;
	float alpha = texture(TEXTURE, UV).a;
	if (alpha < 0.5) {
		float outline = 0.0;
		outline += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
		outline += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
		outline += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
		outline += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
		COLOR = outline > 0.0 ? vec4(1.0, 1.0, 1.0, 1.0) : vec4(0.0);
	} else {
		COLOR = vec4(0.0);
	}
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	return mat

func _on_plant_mouse_entered() -> void:
	if state == State.GROWN:
		border.texture = plant.texture
		border.position = plant.position
		border.size = plant.size
		border.visible = true

func _on_plant_mouse_exited() -> void:
	border.visible = false

func can_plant() -> bool:
	return state == State.EMPTY

func plant_seed(type_name: String) -> void:
	plant_type = type_name
	state = State.SEEDED
	seeded.visible = true
	watered.visible = false
	plant.visible = false

func water() -> void:
	if state == State.SEEDED:
		state = State.WATERED
		watered.visible = true
		seeded.visible = false

func grow() -> void:
	if state == State.WATERED:
		state = State.GROWN
		plant.texture = FarmStand.plant_types[plant_type].tree_texture
		plant.visible = true
		watered.visible = false

func _on_plant_gui_input(event: InputEvent) -> void:
	if state != State.GROWN:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_harvest()

func _harvest() -> void:
	FarmStand.add_harvest(plant_type, 1)
	harvested.emit(plant_type)
	state = State.EMPTY
	plant_type = ""
	plant.visible = false
	seeded.visible = false
	watered.visible = false
	border.visible = false
