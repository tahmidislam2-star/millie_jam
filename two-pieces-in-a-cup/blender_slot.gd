extends TextureButton

@export var slot_index: int = 0

func _ready() -> void:
	DrinkStand.blender_updated.connect(_refresh)
	pressed.connect(_on_pressed)
	_refresh()

func _refresh() -> void:
	var entry = DrinkStand.blender_slots[slot_index]
	if entry:
		texture_normal = DrinkStand.ingredients[entry.name].texture
		visible = true
	else:
		visible = false

func _on_pressed() -> void:
	var entry = DrinkStand.blender_slots[slot_index]
	if entry == null:
		return
	var ing_name = DrinkStand.remove_from_blender(slot_index)
	DrinkStand.return_ingredient(ing_name)
