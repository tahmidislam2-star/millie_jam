extends TextureButton
@export var slot_index: int = 0
var border: TextureRect
@onready var deselect: AudioStreamPlayer = $"../../../deselect"

func _ready() -> void:
	DrinkStand.blender_updated.connect(_refresh)
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	border = TextureRect.new()
	border.material = _make_outline_material()
	border.size = size
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.visible = false
	add_child(border)
	move_child(border, 0)

	_refresh()

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

func _on_mouse_entered() -> void:
	if visible:
		border.visible = true

func _on_mouse_exited() -> void:
	border.visible = false

func _refresh() -> void:
	var entry = DrinkStand.blender_slots[slot_index]
	if entry:
		texture_normal = DrinkStand.ingredients[entry.name].texture
		border.texture = texture_normal
		visible = true
	else:
		visible = false
		border.visible = false

func _on_pressed() -> void:
	var entry = DrinkStand.blender_slots[slot_index]
	if entry == null:
		return
	var ing_name = DrinkStand.remove_from_blender(slot_index)
	deselect.play()
	DrinkStand.return_ingredient(ing_name)
