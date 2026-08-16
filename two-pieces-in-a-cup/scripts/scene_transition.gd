extends CanvasLayer

var wipe_rect: ColorRect
var shader_material: ShaderMaterial

func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS

	wipe_rect = ColorRect.new()
	wipe_rect.color = Color.BLACK
	wipe_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wipe_rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	var shader := load("res://scripts/iris.gdshader")
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set_shader_parameter("radius", 1.5)
	wipe_rect.material = shader_material

	add_child(wipe_rect)
	wipe_rect.visible = false

func change_scene(path: String, wipe_duration: float = 1.5) -> void:
	wipe_rect.visible = true
	shader_material.set_shader_parameter("radius", 1.5)

	var close_tween := create_tween()
	close_tween.tween_method(_set_radius, 1.5, 0.0, wipe_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await close_tween.finished

	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame

	var open_tween := create_tween()
	open_tween.tween_method(_set_radius, 0.0, 1.5, wipe_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await open_tween.finished

	wipe_rect.visible = false

func _set_radius(value: float) -> void:
	shader_material.set_shader_parameter("radius", value)
