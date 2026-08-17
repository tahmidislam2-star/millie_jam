extends TextureButton
@export var ingredient_name: String = ""
@export var sweetness: int = 1
@export var coolness: int = 1
@export var fizziness: int = 1
@export var starting_amount: int = 5
@export var icon_texture: Texture2D
@export var normal_color := Color.WHITE
@export var hover_color := Color(1.2, 1.2, 1.2)
@onready var amount_label: Label = $amount
@onready var select: AudioStreamPlayer = $"../../select"

func _ready() -> void:
	DrinkStand.register_ingredient(ingredient_name, sweetness, coolness, fizziness, starting_amount, icon_texture)
	DrinkStand.blender_updated.connect(_refresh)
	DrinkStand.inventory_changed.connect(_on_inventory_changed)
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_refresh()

func _on_inventory_changed(changed_name: String) -> void:
	if changed_name == ingredient_name:
		_refresh()

func _refresh() -> void:
	amount_label.text = str(DrinkStand.get_amount(ingredient_name))
	disabled = not DrinkStand.has_stock(ingredient_name) or DrinkStand.is_blender_full()

func _on_pressed() -> void:
	if DrinkStand.is_blender_full() or not DrinkStand.has_stock(ingredient_name):
		return
	DrinkStand.use_ingredient(ingredient_name)
	DrinkStand.add_to_blender(ingredient_name)
	select.play()
	_refresh()

func _on_mouse_entered() -> void:
	create_tween().tween_property(self, "modulate", hover_color, 0.08)

func _on_mouse_exited() -> void:
	create_tween().tween_property(self, "modulate", normal_color, 0.08)
