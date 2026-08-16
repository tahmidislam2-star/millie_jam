extends Node2D
signal customer_left(satisfied: bool)

var body_texture: Texture2D
var default_face: Texture2D
var happy_face: Texture2D
var sad_face: Texture2D
var order: Dictionary = {}

@onready var body: Sprite2D = $body
@onready var face: Sprite2D = $face
@onready var sweetness: ProgressBar = $TextureRect/sweetness
@onready var coolness: ProgressBar = $TextureRect/coolness
@onready var fizz: ProgressBar = $TextureRect/fizz

func setup(order_data: Dictionary) -> void:
	order = order_data
	body.texture = body_texture
	face.texture = default_face
	sweetness.max_value = 10
	coolness.max_value = 10
	fizz.max_value = 10
	sweetness.value = order.sweetness
	coolness.value = order.coolness
	fizz.value = order.fizziness

	modulate.a = 0.0
	var fade_in := create_tween()
	fade_in.tween_property(self, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func react(satisfied: bool) -> void:
	face.texture = happy_face if satisfied else sad_face
	await get_tree().create_timer(1.0).timeout

	var fade_out := create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade_out.finished

	customer_left.emit(satisfied)
	queue_free()
