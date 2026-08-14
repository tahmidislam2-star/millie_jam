extends Node

signal blender_updated

var ingredients: Dictionary = {}   
var inventory: Dictionary = {}   
var blender_slots: Array = [null, null] 
var current_order: Dictionary = {}

func register_ingredient(ing_name: String, sweetness: int, coolness: int, fizziness: int, starting_amount: int, icon: Texture2D) -> void:
	ingredients[ing_name] = {"sweetness": sweetness, "coolness": coolness, "fizziness": fizziness, "texture": icon}
	if not inventory.has(ing_name):
		inventory[ing_name] = starting_amount
		
func get_amount(ing_name: String) -> int:
	return inventory.get(ing_name, 0)

func has_stock(ing_name: String) -> bool:
	return get_amount(ing_name) > 0

func use_ingredient(ing_name: String) -> void:
	inventory[ing_name] = get_amount(ing_name) - 1

func return_ingredient(ing_name: String) -> void:
	inventory[ing_name] = get_amount(ing_name) + 1

func is_blender_full() -> bool:
	return blender_slots[0] != null and blender_slots[1] != null

func add_to_blender(ing_name: String) -> int:
	for i in range(2):
		if blender_slots[i] == null:
			blender_slots[i] = {"name": ing_name}
			blender_updated.emit()
			return i
	return -1

func remove_from_blender(slot_index: int) -> String:
	var entry = blender_slots[slot_index]
	blender_slots[slot_index] = null
	blender_updated.emit()
	return entry.name if entry else ""

func get_blended_drink() -> Dictionary:
	var a = ingredients[blender_slots[0].name]
	var b = ingredients[blender_slots[1].name]
	return {
		"sweetness": a.sweetness + b.sweetness,
		"coolness": a.coolness + b.coolness,
		"fizziness": a.fizziness + b.fizziness,
	}
	
func clear_blender() -> void:
	blender_slots = [null, null]
	blender_updated.emit()

func generate_customer_order() -> Dictionary:
	var names = ingredients.keys()
	var a = ingredients[names.pick_random()]
	var b = ingredients[names.pick_random()]

	var stats = {
		"sweetness": min(10, a.sweetness + b.sweetness),
		"coolness": min(10, a.coolness + b.coolness),
		"fizziness": min(10, a.fizziness + b.fizziness),
	}

	var high_keys = []
	for key in stats.keys():
		if stats[key] > 4:
			high_keys.append(key)

	if high_keys.size() >= 2:
		high_keys.shuffle()
		var keep = high_keys.slice(0, 2)
		for key in stats.keys():
			if not keep.has(key):
				stats[key] = randi_range(1, 3)

	current_order = stats
	return current_order

func check_drink_matches(drink: Dictionary) -> bool:
	return drink.sweetness >= current_order.sweetness \
		and drink.coolness >= current_order.coolness \
		and drink.fizziness >= current_order.fizziness
