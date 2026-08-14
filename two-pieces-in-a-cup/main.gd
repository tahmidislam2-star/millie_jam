extends Node2D

const CUSTOMER_SCENE := preload("res://customer.tscn") 

@onready var dress: Sprite2D = $bedroom/dress
@onready var glass: Sprite2D = $bedroom/glass
@onready var hat: Sprite2D = $bedroom/hat
@onready var dresses: MarginContainer = $bedroom/dresses
@onready var dresses_container: MarginContainer = $bedroom/dresses
@onready var hats_container: MarginContainer = $bedroom/hats
@onready var glasses_container: MarginContainer = $bedroom/glasses
@onready var coin_label: Label = $CanvasLayer/coin_label
@onready var item_list: Control = $"item list"
@onready var drink_glass: Node2D = $glass    
@onready var throw: Button = $glass/throw
@onready var serve: Button = $glass/serve
@onready var blender_button: TextureButton = $blender/blender_button
@onready var customer_spawn: Node2D = $customer_spawn

@export var male_bodies: Array[Texture2D] = []      
@export var female_bodies: Array[Texture2D] = []    

@export var male_default_face: Texture2D
@export var male_happy_face: Texture2D
@export var male_sad_face: Texture2D
@export var female_default_face: Texture2D
@export var female_happy_face: Texture2D
@export var female_sad_face: Texture2D

@export var serve_reward: int = 50

var last_gender: bool = true   
var last_idx: int = -1
var slot_sprites := {}
var is_blending := false
var current_drink: Dictionary = {}
var current_customer: Node2D = null

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

	spawn_customer()

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
	await get_tree().create_timer(1.0).timeout
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
	var satisfied := DrinkStand.check_drink_matches(current_drink)
	if satisfied:
		Wardrobe.add_coins(serve_reward)
	current_customer.react(satisfied)
	current_drink = {}
	drink_glass.visible = false

func spawn_customer() -> void:
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
	current_customer = null
	spawn_customer()
