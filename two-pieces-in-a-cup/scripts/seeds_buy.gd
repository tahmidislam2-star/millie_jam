extends TextureButton

@export var plant_name: String = ""
@export var price: int = 20

@onready var price_label: Label = $Label

var border: TextureRect

func _ready() -> void:
	price_label.text = str(price)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)

	border = TextureRect.new()
	border.texture = texture_normal
	border.material = _make_outline_material()
	border.size = size
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.visible = false
	add_child(border)
	move_child(border, 0)

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
	border.visible = true

func _on_mouse_exited() -> void:
	border.visible = false

func _on_pressed() -> void:
	if not Wardrobe.spend(price):
		return
	FarmStand.add_seed(plant_name, 1)
	FarmStand.seed_purchased.emit()
