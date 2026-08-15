extends Node2D

const CUSTOMER_SCENE := preload("res://scenes/customer.tscn") 

@onready var dress: Sprite2D = $bedroom/dress
@onready var glass: Sprite2D = $bedroom/glass
@onready var hat: Sprite2D = $bedroom/hat
@onready var dresses: MarginContainer = $bedroom/dresses
@onready var dresses_container: MarginContainer = $bedroom/dresses
@onready var hats_container: MarginContainer = $bedroom/hats
@onready var glasses_container: MarginContainer = $bedroom/glasses
@onready var coin_label: Label = $CanvasLayer/coin_label

@onready var item_list: Control = $"shop/item list"
@onready var drink_glass: Node2D = $shop/glass
@onready var throw: Button = $shop/glass/throw
@onready var serve: Button = $shop/glass/serve
@onready var blender_button: TextureButton = $shop/blender/blender_button
@onready var customer_spawn: Node2D =$shop/customer_spawn
@onready var animation_player: AnimationPlayer = $shop/blender/AnimationPlayer

@export var male_bodies: Array[Texture2D] = []      
@export var female_bodies: Array[Texture2D] = []    
@onready var camera_2d: Camera2D = $Camera2D

@export var male_default_face: Texture2D
@export var male_happy_face: Texture2D
@export var male_sad_face: Texture2D
@export var female_default_face: Texture2D
@export var female_happy_face: Texture2D
@export var female_sad_face: Texture2D

@export var serve_reward: int = 50

@onready var bed: TextureButton = $bedroom/bed
@onready var day_label: Label = $CanvasLayer/day_label
@onready var farm: Node2D = $farm
@onready var buttons: Control = $farm/buttons
@export var seed_drag_icon: Texture2D

var customers_served_today := 0
var max_customers_today := 0
var last_gender: bool = true   
var last_idx: int = -1
var slot_sprites := {}
var is_blending := false
var current_drink: Dictionary = {}
var current_customer: Node2D = null
var current_day := 1
var current_scene_index := 0
const SCENE_BASE_X := 320
const SCENE_Y := 180
const SCENE_SPACING := 640
const MAX_SCENE_INDEX := 3

#scene 3_boundary
@onready var left_top: Marker2D = $farm/left_top
@onready var right_top: Marker2D = $farm/right_top
@onready var left_bottom: Marker2D = $farm/left_bottom
@onready var right_bottom: Marker2D = $farm/right_bottom

func _ready() -> void:
	slot_sprites = {"dress": dress, "glass": glass, "hat": hat}
	Wardrobe.item_equipped.connect(_on_item_equipped)
	Wardrobe.item_unequipped.connect(_on_item_unequipped)
	Wardrobe.coins_changed.connect(_on_coins_changed)
	coin_label.text = str(Wardrobe.coins)

	blender_button.pressed.connect(_on_blender_button_pressed)
	throw.pressed.connect(_on_throw_pressed)
	serve.pressed.connect(_on_serve_pressed)
	drink_glass.visible = false
	
	max_customers_today = randi_range(4, 5)
	spawn_customer()

	FarmStand.seed_icon_texture = seed_drag_icon
	bed.pressed.connect(_on_bed_pressed)
	day_label.text = "DAY %d" % current_day
	WorldBounds.set_bounds(
		left_top.global_position,
		right_top.global_position,
		left_bottom.global_position,
		right_bottom.global_position
	)
	camera_2d.position = Vector2(SCENE_BASE_X, SCENE_Y)

func _on_coins_changed(new_amount: int) -> void:
	coin_label.text = str(new_amount)

func _on_item_equipped(item_type: String, texture: Texture2D) -> void:
	if slot_sprites.has(item_type):
		slot_sprites[item_type].texture = texture
		slot_sprites[item_type].visible = true

func _on_item_unequipped(item_type: String) -> void:
	if slot_sprites.has(item_type):
		slot_sprites[item_type].visible = false

func _on_cross_button_pressed() -> void:
	dresses_container.visible = false
	hats_container.visible = false
	glasses_container.visible = false

func _on_hatbutton_pressed() -> void:
	dresses_container.visible = false
	hats_container.visible = true
	glasses_container.visible = false

func _on_glassesbutton_pressed() -> void:
	dresses_container.visible = false
	hats_container.visible = false
	glasses_container.visible = true

func _on_dressbutton_pressed() -> void:
	dresses_container.visible = true
	hats_container.visible = false
	glasses_container.visible = false


func _on_blender_button_pressed() -> void:
	if is_blending or not DrinkStand.is_blender_full():
		return
	is_blending = true
	blender_button.disabled = true
	animation_player.play("on")
	await animation_player.animation_finished
	animation_player.play("default")
	current_drink = DrinkStand.get_blended_drink()
	DrinkStand.clear_blender()
	drink_glass.visible = true
	is_blending = false
	blender_button.disabled = false


func _on_throw_pressed() -> void:
	current_drink = {}
	drink_glass.visible = false

func _on_serve_pressed() -> void:
	if current_customer == null or current_drink.is_empty():
		return
	print("Target order: ", DrinkStand.current_order)
	print("Made drink: ", current_drink)
	var satisfied = DrinkStand.check_drink_matches(current_drink)
	if satisfied:
		Wardrobe.add_coins(serve_reward)
	current_customer.react(satisfied)
	current_drink = {}
	drink_glass.visible = false

func spawn_customer() -> void:
	if customers_served_today >= max_customers_today:
		current_customer = null
		return

	var is_male: bool
	var idx: int

	while true:
		is_male = randf() < 0.5
		idx = randi() % 5
		if is_male != last_gender or idx != last_idx:
			break

	last_gender = is_male
	last_idx = idx

	var c := CUSTOMER_SCENE.instantiate()

	if is_male:
		c.body_texture = male_bodies[idx]
		c.default_face = male_default_face
		c.happy_face = male_happy_face
		c.sad_face = male_sad_face
	else:
		c.body_texture = female_bodies[idx]
		c.default_face = female_default_face
		c.happy_face = female_happy_face
		c.sad_face = female_sad_face

	add_child(c)
	c.global_position = customer_spawn.global_position
	c.customer_left.connect(_on_customer_left)
	current_customer = c
	c.setup(DrinkStand.generate_customer_order())

func _on_customer_left(_satisfied: bool) -> void:
	customers_served_today += 1
	current_customer = null
	spawn_customer()

func _on_bed_pressed() -> void:
	current_day += 1
	day_label.text = "DAY %d" % current_day
	for plot in get_tree().get_nodes_in_group("plots"):
		plot.grow()

	if current_customer != null:
		current_customer.customer_left.disconnect(_on_customer_left)
		current_customer.queue_free()
		current_customer = null

	customers_served_today = 0
	max_customers_today = randi_range(4, 5)
	spawn_customer()


func _on_next_pressed() -> void:
	if current_scene_index >= MAX_SCENE_INDEX:
		return
	current_scene_index += 1
	_move_camera_to_scene(current_scene_index)

func _on_prev_pressed() -> void:
	if current_scene_index <= 0:
		return
	current_scene_index -= 1
	_move_camera_to_scene(current_scene_index)

func _move_camera_to_scene(index: int) -> void:
	var target_x := SCENE_BASE_X + (SCENE_SPACING * index)
	var target_pos := Vector2(target_x, SCENE_Y)
	create_tween().tween_property(camera_2d, "position", target_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
