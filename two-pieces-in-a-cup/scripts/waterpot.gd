extends Area2D
@onready var water_animation_player: AnimationPlayer = $water_animation_player
@onready var water: Sprite2D = $water
@onready var shadow: Sprite2D = $Shadow
@onready var pour_point: Marker2D = $Marker2D
@onready var can_sprite: Sprite2D = $Watercan
var dragging := false
var original_position: Vector2
var target_plot: Control = null
var border: Sprite2D

func _ready() -> void:
	original_position = position
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	border = Sprite2D.new()
	border.texture = can_sprite.texture
	border.material = _make_outline_material()
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
	if not dragging:
		border.visible = true

func _on_mouse_exited() -> void:
	border.visible = false

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not dragging:
		dragging = true
		shadow.visible = false
		border.visible = false
		rotation_degrees = -60

func _process(_delta: float) -> void:
	if not dragging:
		return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_release()
		return
	global_position = WorldBounds.clamp_point(get_global_mouse_position())
	var check_pos := pour_point.global_position
	var found: Control = null
	for plot in get_tree().get_nodes_in_group("plots"):
		if plot.state == plot.State.SEEDED and plot.get_global_rect().has_point(check_pos):
			found = plot
			break
	if found and found != target_plot:
		target_plot = found
		water.visible = true
		water_animation_player.play("pour")
		target_plot.water()
	elif not found and target_plot:
		target_plot = null

func _release() -> void:
	dragging = false
	rotation_degrees = 0
	shadow.visible = true
	target_plot = null
	water_animation_player.stop()
	water.visible = false
	position = original_position
