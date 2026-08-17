extends Node2D

# ---------- UI / Announcer ----------
@onready var announcer: Label = $CanvasLayer/announcer
@onready var next_button: TextureButton = $CanvasLayer/next
@onready var prev_button: TextureButton = $CanvasLayer/prev
@onready var camera_2d: Camera2D = $Camera2D
@onready var coin_label: Label = $CanvasLayer/coin_label
@onready var eye_glass: Sprite2D = $bedroom/glass

const SCENE_BASE_X := 320
const SCENE_Y := 180
const SCENE_SPACING := 640
var current_scene_index := 0

# ---------- Shop ----------
@onready var customer: Node2D = $shop/customer
@onready var face: Sprite2D = $shop/customer/face
@export var customer_happy_face: Texture2D

@onready var lemon: TextureButton = $"shop/item list/Lemon"
@onready var l_amount: Label = $"shop/item list/Lemon/amount"

@onready var sugarcane: TextureButton = $"shop/item list/Sugarcane"
@onready var s_amount: Label = $"shop/item list/Sugarcane/amount"

@onready var item_1: TextureButton = $shop/blender/items/item1
@onready var item_2: TextureButton = $shop/blender/items/item2
@onready var blender_button: TextureButton = $shop/blender/blender_button
@onready var blender_animation: AnimationPlayer = $shop/blender/AnimationPlayer

@export var lemon_blender_texture: Texture2D
@export var sugarcane_blender_texture: Texture2D

@onready var glass_texture: Sprite2D = $shop/glass/Glass_texture
@onready var serve: Button = $shop/glass/serve
@onready var throw: Button = $shop/glass/throw

# ---------- Farm ----------
@onready var lemon_tree: TextureButton = $farm/lemon_tree
@onready var sugarcane_tree: TextureButton = $farm/sugarcane_tree
@onready var plots: Control = $farm/Control/plots
@onready var waterpot: Area2D = $farm/waterpot
@onready var water: Sprite2D = $farm/waterpot/water
@onready var water_animation_player: AnimationPlayer = $farm/waterpot/water_animation_player
@export var seed_drag_icon: Texture2D
@onready var lemon_seed: TextureButton = $farm/buttons/lemon
@onready var lemon_seed_amount: Label = $farm/buttons/lemon/amount

@onready var left_top: Marker2D = $farm/left_top
@onready var right_top: Marker2D = $farm/right_top
@onready var left_bottom: Marker2D = $farm/left_bottom
@onready var right_bottom: Marker2D = $farm/right_bottom

# ---------- Seed shop ----------
@onready var lemon_seed_button: TextureButton = $seed_shop/lemon 
@onready var shopkeeper_label: Label = $"seed_shop/Dialogue Box/Label"
@onready var dialogue_box: Panel = $"seed_shop/Dialogue Box"


# ---------- Bedroom ----------
@onready var glassesbutton: TextureButton = $bedroom/buttons/glassesbutton
@onready var simple_glass: TextureButton = $bedroom/simple_glass
@onready var glass: Sprite2D = $bedroom/glass
@onready var bed: TextureButton = $bedroom/bed



const TYPEWRITER_SPEED := 0.05
signal step_condition_met
var _trees_harvested := 0
var base_coins = 320
var _dragging_seed := false
var _seed_drag_node: Sprite2D
var tut_lemon := 0
var tut_sugarcane := 0
var tut_blender_slots: Array = [null, null]

func _ready() -> void:
	WorldBounds.set_bounds(
		left_top.global_position,
		right_top.global_position,
		left_bottom.global_position,
		right_bottom.global_position
	)

	camera_2d.position = Vector2(SCENE_BASE_X, SCENE_Y)


	_setup_tutorial_inventory()
	
	serve.visible = false
	throw.visible = false
	glass_texture.visible = false
	simple_glass.visible = false
	coin_label.text = str(base_coins)
	_lock_all()
	_run_tutorial()
	lemon.pressed.connect(_on_lemon_pressed)
	sugarcane.pressed.connect(_on_sugarcane_pressed)
	lemon_seed.button_down.connect(_start_seed_drag)
# ---------------- Lock helpers ----------------
func _setup_tutorial_inventory() -> void:
	tut_lemon = 1
	tut_sugarcane = 1
	l_amount.text = str(tut_lemon)
	s_amount.text = str(tut_sugarcane)
		
func _lock_all() -> void:
	next_button.disabled = true
	prev_button.disabled = true
	lemon.disabled = true
	sugarcane.disabled = true
	blender_button.disabled = true
	serve.disabled = true
	throw.disabled = true
	serve.mouse_filter = Control.MOUSE_FILTER_IGNORE
	throw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lemon_tree.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sugarcane_tree.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lemon_seed_button.disabled = true
	lemon_seed.disabled = true
	waterpot.input_pickable = false
	for plot in plots.get_children():
		if plot.has_node("plant"):
			plot.get_node("plant").mouse_filter = Control.MOUSE_FILTER_IGNORE
	glassesbutton.disabled = true
	simple_glass.disabled = true
	bed.disabled = true
	lemon_seed.disabled = true
func _say(text: String, hold: float = 1.2) -> void:
	announcer.text = ""
	for i in text.length():
		announcer.text += text[i]
		await get_tree().create_timer(TYPEWRITER_SPEED).timeout
	if hold > 0.0:
		await get_tree().create_timer(hold).timeout
		
# ---------------- Camera / scene nav ----------------

func _move_camera_to_scene(index: int) -> void:
	current_scene_index = index
	var target_pos := Vector2(SCENE_BASE_X + SCENE_SPACING * index, SCENE_Y)
	var tween := create_tween()
	tween.tween_property(camera_2d, "position", target_pos, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

# ---------------- Main sequence ----------------

func _run_tutorial() -> void:
	await _say("Hello Millie, slept well?")
	await _say("Your juice stand is waiting for you.")

	await _say("Press the \"->\" button on the top right of your screen to visit your shop.", 0.0)
	next_button.disabled = false
	await next_button.pressed
	next_button.disabled = true
	await _move_camera_to_scene(1)

	await _say("There's a customer.")
	await _say("Looks like he wants a cool sweet drink.")

	await _say("Press the lemon and sugarcane to add them in your blender.", 0.0)
	lemon.disabled = false
	sugarcane.disabled = false
	await _wait_for_blender_full()
	lemon.disabled = true
	sugarcane.disabled = true

	await _say("Press the blender button to make the juice.")
	blender_button.disabled = false
	await blender_button.pressed
	blender_button.disabled = true
	await _play_blend_animation()
	item_1.texture_normal = null
	item_2.texture_normal = null
	item_1.visible=false
	item_2.visible=false
	
	await _say("The juice is ready to serve.")
	serve.visible = true
	throw.visible = true
	await  _say("")
	serve.mouse_filter = Control.MOUSE_FILTER_STOP
	serve.disabled = false
	await serve.pressed
	serve.disabled = true
	serve.visible=false
	throw.visible=false
	serve.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.texture = customer_happy_face
	var fade_out := create_tween()
	fade_out.tween_property(customer, "modulate:a", 0.0, 0.4)
	await fade_out.finished
	
	base_coins += 200
	coin_label.text = str(base_coins)
	glass_texture.visible = false

	await _say("You are out of ingredients. Press the \"->\" button again to visit your farm.")
	next_button.disabled = false
	await next_button.pressed
	next_button.disabled = true
	await _move_camera_to_scene(2)

	await _say("Press the trees to harvest them.", 0.0)
	lemon_tree.mouse_filter = Control.MOUSE_FILTER_STOP
	sugarcane_tree.mouse_filter = Control.MOUSE_FILTER_STOP
	await _wait_for_both_harvested()

	await _say("You should also get some seeds while you are at it.")
	await _say("Press the \"->\" button again to visit the seed shop.", 0.0)
	next_button.disabled = false
	await next_button.pressed
	next_button.disabled = true
	await _move_camera_to_scene(3)

	await _say("Buy one lemon seed.", 0.0)
	lemon_seed_button.disabled = false
	await lemon_seed_button.pressed
	base_coins -= 20
	coin_label.text = str(base_coins)
	lemon_seed_button.disabled = true
	var line: String = "Thank you. Please visit again!"
	shopkeeper_label.text = ""
	dialogue_box.visible = true
	for i in line.length():
		shopkeeper_label.text += line[i]
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(1.0).timeout
	dialogue_box.visible = false
	
	await _say("Press the \"<-\" button to return to the farm", 0.0)
	prev_button.disabled = false
	await prev_button.pressed
	prev_button.disabled = true
	await _move_camera_to_scene(2)
	
	await _say("Drag the seed you bought and plant it. Anywhere.", 0.0)
	lemon_seed.disabled = false
	lemon_seed_amount.text = "1"
	await _wait_for_any_plot_seeded()
	lemon_seed.disabled = true
	await _say("Now water the plant.", 0.0)
	
	waterpot.input_pickable = true
	await _wait_for_any_plot_watered()
	waterpot.input_pickable = false

	await _say("Return to the bedroom by clicking \"<-\" twice.", 0.0)
	prev_button.disabled = false
	await prev_button.pressed
	await _move_camera_to_scene(1)
	await prev_button.pressed
	prev_button.disabled = true
	await _move_camera_to_scene(0)

	await _say("You can buy dresses and accessories using your coins.", 0.0)
	await get_tree().create_timer(1.0).timeout
	await  _say("Press the glasses icon on the left side of the screen.", 0.0)
	glassesbutton.disabled = false
	await glassesbutton.pressed
	glassesbutton.disabled = true
	simple_glass.visible = true

	await _say("Buy the glasses for yourself.", 0.0)
	simple_glass.disabled = false
	await simple_glass.pressed
	base_coins -= 500
	coin_label.text = str(base_coins)
	simple_glass.disabled = true
	eye_glass.visible= true
	await _say("Now go to sleep and end the day.", 0.0)
	bed.disabled = false
	await bed.pressed
	SceneTransition.change_scene("res://scenes/main.tscn")
	

# ---------------- Wait helpers ----------------

func _wait_for_blender_full() -> void:
	while not _tut_is_blender_full():
		await get_tree().process_frame
		
func _play_blend_animation() -> void:
	blender_animation.play("on")
	await blender_animation.animation_finished
	blender_animation.play("default")
	glass_texture.visible = true
	_tut_clear_blender()
	
func _wait_for_both_harvested() -> void:
	_trees_harvested = 0
	lemon_tree.pressed.connect(_on_lemon_tree_pressed, CONNECT_ONE_SHOT)
	sugarcane_tree.pressed.connect(_on_sugarcane_tree_pressed, CONNECT_ONE_SHOT)
	while _trees_harvested < 2:
		await step_condition_met

func _wait_for_any_plot_seeded() -> void:
	while true:
		for plot in plots.get_children():
			if plot.state == plot.State.SEEDED:
				return
		
		await get_tree().process_frame
		
func _wait_for_any_plot_watered() -> void:
	while true:
		for plot in plots.get_children():
			if plot.state == plot.State.WATERED:
				return
		
		await get_tree().process_frame
		
func _on_lemon_pressed() -> void:
	if tut_lemon <= 0:
		return
	var slot := _tut_add_to_blender("Lemon")
	if slot == -1:
		return
	tut_lemon -= 1
	l_amount.text = str(tut_lemon)
	_update_blender_slot(slot, lemon_blender_texture)

func _on_sugarcane_pressed() -> void:
	if tut_sugarcane <= 0:
		return
	var slot := _tut_add_to_blender("Sugarcane")
	if slot == -1:
		return
	tut_sugarcane -= 1
	s_amount.text = str(tut_sugarcane)
	_update_blender_slot(slot, sugarcane_blender_texture)
	
func _tut_is_blender_full() -> bool:
	return tut_blender_slots[0] != null and tut_blender_slots[1] != null

func _tut_add_to_blender(ing_name: String) -> int:
	for i in range(2):
		if tut_blender_slots[i] == null:
			tut_blender_slots[i] = ing_name
			return i
	return -1

func _tut_clear_blender() -> void:
	tut_blender_slots = [null, null]
		
func _update_blender_slot(slot: int, texture: Texture2D) -> void:
	var target: TextureButton = item_1 if slot == 0 else item_2
	target.texture_normal = texture
	target.visible = true

func _on_sugarcane_tree_pressed() -> void:
	s_amount.text = "1"
	_trees_harvested += 1
	step_condition_met.emit()
	sugarcane_tree.queue_free()

func _on_lemon_tree_pressed() -> void:
	l_amount.text = "1"
	_trees_harvested += 1
	step_condition_met.emit()
	lemon_tree.queue_free()
	
func _start_seed_drag() -> void:
	if _dragging_seed:
		return
	_dragging_seed = true
	_seed_drag_node = Sprite2D.new()
	_seed_drag_node.texture = seed_drag_icon
	_seed_drag_node.z_index = 100
	add_child(_seed_drag_node)
	_seed_drag_node.global_position = WorldBounds.clamp_point(get_global_mouse_position())
	
func _process(_delta: float) -> void:
	if not _dragging_seed:
		return

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_end_seed_drag()
		return

	_seed_drag_node.global_position = WorldBounds.clamp_point(
		get_global_mouse_position()
	)

func _input(event: InputEvent) -> void:
	if _dragging_seed and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_end_seed_drag()

func _end_seed_drag() -> void:
	_dragging_seed = false
	
	var drop_pos: Vector2 = WorldBounds.clamp_point(
		get_global_mouse_position()
	)
	
	for plot in get_tree().get_nodes_in_group("plots"):
		if plot.state == plot.State.EMPTY and plot.get_global_rect().has_point(drop_pos):
			plot.plant()
			break
	
	if _seed_drag_node:
		_seed_drag_node.queue_free()
		_seed_drag_node = null

func _plant_seed_on(plot: Control) -> void:
	if plot.has_method("plant_seed"):
		plot.plant_seed()
	else:
		plot.state = plot.State.SEEDED
		if plot.has_node("plant"):
			plot.get_node("plant").visible = true

func _clamp_to_world_bounds(pos: Vector2) -> Vector2:
	var min_x: float = min(left_top.global_position.x, left_bottom.global_position.x)
	var max_x: float = max(right_top.global_position.x, right_bottom.global_position.x)
	var min_y: float = min(left_top.global_position.y, right_top.global_position.y)
	var max_y: float = max(left_bottom.global_position.y, right_bottom.global_position.y)
	return Vector2(clamp(pos.x, min_x, max_x), clamp(pos.y, min_y, max_y))
