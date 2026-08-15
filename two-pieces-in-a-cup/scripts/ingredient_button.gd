extends TextureButton

@export var ingredient_name: String = ""
@export var sweetness: int = 1
@export var coolness: int = 1
@export var fizziness: int = 1
@export var starting_amount: int = 5
@export var icon_texture: Texture2D

@onready var amount_label: Label = $amount

func _ready() -> void:
	DrinkStand.register_ingredient(ingredient_name, sweetness, coolness, fizziness, starting_amount, icon_texture)
	DrinkStand.blender_updated.connect(_refresh)
	DrinkStand.inventory_changed.connect(_on_inventory_changed)
	pressed.connect(_on_pressed)
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
	_refresh()
