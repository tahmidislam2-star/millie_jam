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
@onready var millie: Node2D = $bedroom/millie
@onready var heart: Sprite2D = $bedroom/heart
@onready var heart_animation: AnimationPlayer = $bedroom/heart_animation
@onready var cato: Sprite2D = $bedroom/millie/Cato
@onready var pet_area: Area2D = $bedroom/millie/pat_area

@onready var item_list: Control = $"shop/item list"
@onready var drink_glass: Node2D = $shop/glass
@onready var throw: Button = $shop/glass/throw
@onready var serve: Button = $shop/glass/serve
@onready var blender_button: TextureButton = $shop/blender/blender_button
@onready var customer_spawn: Node2D =$shop/customer_spawn
@onready var animation_player: AnimationPlayer = $shop/blender/AnimationPlayer

@onready var sleep_pos: Marker2D = $"bedroom/sleep pos"
@onready var regular_pos: Marker2D = $"bedroom/regular pos"
@onready var blackout: Panel = $bedroom/blackout
@onready var skip_button: Button = $shop/skip


@export var male_bodies: Array[Texture2D] = []      
@export var female_bodies: Array[Texture2D] = []    
@onready var camera_2d: Camera2D = $Camera2D
@onready var throw_sprite: Sprite2D = $shop/Throw
@onready var throw_sprite_animation: AnimationPlayer = $shop/Throw/throw_animation
@onready var throw_sound_water: AudioStreamPlayer = $shop/glass/throw_sound_water

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
@onready var dialogue_box: Panel = $"seed_shop/Dialogue Box"
@onready var label: Label = $"seed_shop/Dialogue Box/Label"
@onready var hint_label: Label = $shop/hint_label
@onready var pause_menu: Panel = $CanvasLayer/pause_menu
@onready var yes: Button = $CanvasLayer/pause_menu/Yes
@onready var slide: AudioStreamPlayer = $CanvasLayer/slide
@onready var blend: AudioStreamPlayer = $shop/blender/blend
@onready var serve_sound: AudioStreamPlayer = $shop/glass/serve_sound
@onready var throw_sound: AudioStreamPlayer = $shop/glass/throw_sound
@onready var light_sound: AudioStreamPlayer = $bedroom/light
@onready var cat_meow: AudioStreamPlayer = $bedroom/cat_meow
@onready var click_sound: AudioStreamPlayer = $CanvasLayer/click
@onready var hover_text: Label = $hover_text
@onready var hint_button: TextureButton = $shop/Hint


var dialogue_lines: Array[String] = [
	"You remind me of myself when I was younger.",
	"Thank you.",
	"What else do you need?",
	"Anything else in your mind?",
	"I will be here if you need me.",
	"This is the oldest shop in town.",
	"Take good care of your plants.",
	"Good season for harvesting.",
	"Nice weather today.",
	"I will visit your stand one day.",
	"What's good?",
	"Millicious.",
	"Bright and sunny today.",
	"Nice to have a fellow plant lover around.",
	"That will grow great.",
	"How's your day going?",
	"Whatever you need.",
	"Nice day for fishing, huhah.",
	"It's dangerous to go alone! Take this.",
]


var is_dialogue_showing := false
const TYPEWRITER_SPEED := 0.03
const DIALOGUE_HOLD_TIME := 1.5

var shop_closed_text: String = ""
var is_throwing := false
var is_hint_showing := false
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
var is_sleeping := false
var is_moving := false
const HOVER_TEXT_OFFSET := Vector2(28, -16)
var hover_text_active := false
const SCENE_BASE_X := 320
const SCENE_Y := 180
const SCENE_SPACING := 640
const MAX_SCENE_INDEX := 3
const SHOP_CLOSED_HOLD_TIME := 2.0
const DAILY_FREE_SEED_POOL := ["Lemon", "Sugarcane", "Mint", "Cucumber"]
const DAILY_FREE_SEED_COUNT := 4

#scene 3_boundary
@onready var left_top: Marker2D = $farm/left_top
@onready var right_top: Marker2D = $farm/right_top
@onready var left_bottom: Marker2D = $farm/left_bottom
@onready var right_bottom: Marker2D = $farm/right_bottom

func _ready() -> void:
	DrinkStand.reset_state()
	DrinkStand.inventory = { "Lemon": 3, 
		"Sugarcane": 3, 
		"Mint": 3, 
		"Cucumber": 3, 
		"Hibiscus": 2, 
		"Ginger": 2, 
		"Watermelon": 0, 
		"Strawberry": 0, 
		"Passionfruit": 0, 
		"Lavender": 0 }
	for ing_name in DrinkStand.inventory.keys():
		DrinkStand.inventory_changed.emit(ing_name)
	
	FarmStand.seeds = {"Lemon": 2, 
	"Sugarcane": 2, 
	"Mint": 2, 
	"Cucumber": 2, 
	"Ginger": 2, 
	"Hibiscus": 2, 
	"Strawberry": 1, 
	"Watermelon": 1, 
	"Lavender": 0, 
	"Passionfruit": 0 }
	for seed_name in FarmStand.seeds.keys():
		FarmStand.seeds_changed.emit(seed_name) 

	Wardrobe.coins= 300
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

	FarmStand.seed_purchased.connect(_on_seed_purchased)
	heart.visible = false
	pet_area.petted.connect(_on_petted)
	pet_area.pet_stopped.connect(_on_pet_stopped)
	shop_closed_text = hint_label.text
	hint_label.visible = false
	hint_label.text = ""
	hover_text.visible = false
	hover_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	HoverBus.hover_started.connect(_on_hover_started)
	HoverBus.hover_ended.connect(_on_hover_ended)
	
func _on_coins_changed(new_amount: int) -> void:
	coin_label.text = str(new_amount)

func _on_item_equipped(item_type: String, texture: Texture2D) -> void:
	if slot_sprites.has(item_type):
		slot_sprites[item_type].texture = texture
		slot_sprites[item_type].visible = true
		slot_sprites[item_type].modulate.a = 1.0

func _on_item_unequipped(item_type: String) -> void:
	if slot_sprites.has(item_type):
		slot_sprites[item_type].visible = false

func _on_cross_button_pressed() -> void:
	slide.play()
	dresses_container.visible = false
	hats_container.visible = false
	glasses_container.visible = false

func _on_hatbutton_pressed() -> void:
	slide.play()
	dresses_container.visible = false
	hats_container.visible = true
	glasses_container.visible = false

func _on_glassesbutton_pressed() -> void:
	slide.play()
	dresses_container.visible = false
	hats_container.visible = false
	glasses_container.visible = true

func _on_dressbutton_pressed() -> void:
	slide.play()
	dresses_container.visible = true
	hats_container.visible = false
	glasses_container.visible = false


func _on_blender_button_pressed() -> void:
	if is_blending or not DrinkStand.is_blender_full():
		return
	is_blending = true
	blender_button.disabled = true
	animation_player.play("on")
	blend.play()
	await animation_player.animation_finished
	animation_player.play("default")
	blend.stop()
	current_drink = DrinkStand.get_blended_drink()
	DrinkStand.clear_blender()
	drink_glass.visible = true
	is_blending = false
	blender_button.disabled = false


func _on_throw_pressed() -> void:
	throw_sound.play()
	current_drink = {}
	drink_glass.visible = false

func _on_serve_pressed() -> void:
	if current_customer == null or current_drink.is_empty():
		return
	serve_sound.play()
	var satisfied = DrinkStand.check_drink_matches(current_drink)
	if satisfied:
		Wardrobe.add_coins(serve_reward)
	current_customer.react(satisfied)
	current_drink = {}
	drink_glass.visible = false

func spawn_customer() -> void:
	if customers_served_today >= max_customers_today:
		current_customer = null
		_show_shop_closed()
		skip_button.disabled = true
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
	c.setup(DrinkStand.generate_customer_order(current_day))
	skip_button.disabled = false

func _on_customer_left(_satisfied: bool) -> void:
	customers_served_today += 1
	current_customer = null
	spawn_customer()

func _on_bed_pressed() -> void:
	if is_sleeping:
		return
	is_sleeping = true

	dresses_container.visible = false
	hats_container.visible = false
	glasses_container.visible = false

	var fade_out_group := create_tween().set_parallel(true)
	fade_out_group.tween_property(millie, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if dress.visible:
		fade_out_group.tween_property(dress, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if glass.visible:
		fade_out_group.tween_property(glass, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if hat.visible:
		fade_out_group.tween_property(hat, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade_out_group.finished

	millie.position = sleep_pos.position
	dress.visible = false
	glass.visible = false
	hat.visible = false

	var fade_in_millie := create_tween()
	fade_in_millie.tween_property(millie, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade_in_millie.finished
	light_sound.play()
	blackout.visible = true
	blackout.modulate.a = 0.0
	var fade_in := create_tween()
	fade_in.tween_property(blackout, "modulate:a", 1.0, 0.6)
	await fade_in.finished

	# day advance
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
	_grant_daily_seeds()
	spawn_customer()
	# fade in day

	await get_tree().create_timer(1.0).timeout

	var fade_out := create_tween()
	fade_out.tween_property(blackout, "modulate:a", 0.0, 0.6)
	await fade_out.finished
	blackout.visible = false

	var fade_out_millie2 := create_tween()
	fade_out_millie2.tween_property(millie, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade_out_millie2.finished

	millie.position = regular_pos.position

	dress.visible = Wardrobe.equipped.has("dress")
	glass.visible = Wardrobe.equipped.has("glass")
	hat.visible = Wardrobe.equipped.has("hat")
	dress.modulate.a = 0.0
	glass.modulate.a = 0.0
	hat.modulate.a = 0.0

	var fade_in_group := create_tween().set_parallel(true)
	fade_in_group.tween_property(millie, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if dress.visible:
		fade_in_group.tween_property(dress, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if glass.visible:
		fade_in_group.tween_property(glass, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if hat.visible:
		fade_in_group.tween_property(hat, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await fade_in_group.finished

	is_sleeping = false
	
func _on_next_pressed() -> void:
	if is_sleeping or current_scene_index >= MAX_SCENE_INDEX:
		return
	current_scene_index += 1
	slide.play()
	_move_camera_to_scene(current_scene_index)
	is_moving = false
	
func _on_prev_pressed() -> void:
	if is_sleeping or current_scene_index <= 0:
		return
	current_scene_index -= 1
	slide.play()
	_move_camera_to_scene(current_scene_index)
	is_moving = false
	
func _move_camera_to_scene(index: int) -> void:
	var target_x := SCENE_BASE_X + (SCENE_SPACING * index)
	var target_pos := Vector2(target_x, SCENE_Y)
	create_tween().tween_property(camera_2d, "position", target_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	is_moving = true
	
func _on_seed_purchased() -> void:
	if is_dialogue_showing:
		return
	_show_random_dialogue()

func _show_random_dialogue() -> void:
	is_dialogue_showing = true
	var line: String = dialogue_lines[randi() % dialogue_lines.size()]
	label.text = ""
	dialogue_box.visible = true

	for i in line.length():
		label.text += line[i]
		await get_tree().create_timer(TYPEWRITER_SPEED).timeout

	await get_tree().create_timer(DIALOGUE_HOLD_TIME).timeout

	dialogue_box.visible = false
	is_dialogue_showing = false
	
func _grant_daily_seeds() -> void:
	for i in DAILY_FREE_SEED_COUNT:
		var pick: String = DAILY_FREE_SEED_POOL[randi() % DAILY_FREE_SEED_POOL.size()]
		FarmStand.add_seed(pick, 1)

func _show_shop_closed() -> void:
	skip_button.disabled = true
	await _show_hint_message(shop_closed_text)
	
func _on_close_pressed() -> void:
	if is_moving: 
		return
		
	get_tree().paused = true
	pause_menu.visible = true
	
func _on_petted() -> void:
	if is_sleeping:
		return

	heart.visible = true
	heart_animation.play("pat_heart")

	if not cat_meow.playing:
		cat_meow.play()
		
func _on_pet_stopped() -> void:
	heart_animation.stop()
	heart.visible = false


func _on_yes_pressed() -> void:
	get_tree().paused = false
	yes.disabled = true
	SceneTransition.change_scene("res://scenes/main_menu.tscn")
	click_sound.play()

func _on_no_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false
	click_sound.play()


func _on_skip_pressed() -> void:
	if current_customer == null:
		return
	current_customer.react(false)
	skip_button.disabled = true

func _on_hover_started(message: String) -> void:
	if get_tree().paused:
		return
	hover_text.text = message
	hover_text.visible = true
	hover_text_active = true

func _on_hover_ended() -> void:
	hover_text.visible = false
	hover_text_active = false

func _process(_delta: float) -> void:
	if hover_text_active:
		hover_text.global_position = get_global_mouse_position() - HOVER_TEXT_OFFSET


func _show_hint_message(text: String) -> void:
	is_hint_showing = true
	hint_button.disabled = true
	hint_label.visible = true
	hint_label.text = ""

	for i in text.length():
		hint_label.text += text[i]
		await get_tree().create_timer(TYPEWRITER_SPEED).timeout

	await get_tree().create_timer(SHOP_CLOSED_HOLD_TIME).timeout

	hint_label.visible = false
	hint_label.text = ""
	hint_button.disabled = false
	is_hint_showing = false
	
func _on_hint_pressed() -> void:
	if is_hint_showing:
		return

	if current_customer == null:
		_show_hint_message("Sleep to end the day.")
		return

	var pair := DrinkStand.get_hint_pair(true)
	if not pair.is_empty():
		if pair[0] == pair[1]:
			_show_hint_message("Try two %s." % pair[0])
		else:
			_show_hint_message("Try %s and %s." % [pair[0], pair[1]])
		return

	var any_combo := DrinkStand.get_hint_pair(false)
	if any_combo.is_empty():
		_show_hint_message("No matching combo found.")
	else:
		_show_hint_message("You don't have the ingredients for this.")


func _on_throw_2_pressed() -> void:
	if is_throwing or current_customer == null:
		return
	is_throwing = true

	throw_sound.play()
	throw_sprite.modulate.a = 1.0
	throw_sprite.visible = true
	throw_sprite_animation.play("throw")
	throw_sound_water.play()
	await throw_sprite_animation.animation_finished

	var fade_out := create_tween()
	fade_out.tween_property(throw_sprite, "modulate:a", 0.0, 0.5)
	current_customer.react(false)
	await fade_out.finished
	throw_sprite.visible = false

	current_drink = {}
	drink_glass.visible = false
	
	skip_button.disabled = true

	is_throwing = false
