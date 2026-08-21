extends Node

signal blender_updated

var ingredients: Dictionary = {}   
var inventory: Dictionary = {}   
var blender_slots: Array = [null, null] 
var current_order: Dictionary = {}
signal inventory_changed(ing_name: String)

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
	inventory_changed.emit(ing_name)

func add_ingredient_stock(ing_name: String, amount: int = 1) -> void:
	inventory[ing_name] = get_amount(ing_name) + amount
	inventory_changed.emit(ing_name)
	
func return_ingredient(ing_name: String) -> void:
	inventory[ing_name] = get_amount(ing_name) + 1
	inventory_changed.emit(ing_name)

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

func generate_customer_order(day: int = 1) -> Dictionary:
	var keys := ["sweetness", "coolness", "fizziness"]
	keys.shuffle()
	var stats := {}

	if day <= 4:
		# Tier 1: one dominant stat, everything else near-zero
		stats[keys[0]] = randi_range(7, 9)
		stats[keys[1]] = randi_range(1, 2)
		stats[keys[2]] = randi_range(1, 2)

	elif day <= 8:
		# Tier 2: one high, one medium, one low
		stats[keys[0]] = randi_range(7, 9)
		stats[keys[1]] = randi_range(4, 6)
		stats[keys[2]] = randi_range(1, 3)

	else:
		# Tier 3: original logic — two high stats from a random ingredient pair
		var names = ingredients.keys()
		var a = ingredients[names.pick_random()]
		var b = ingredients[names.pick_random()]
		stats = {
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

func reset_state() -> void:
	blender_slots = [null, null]
	current_order.clear()
	blender_updated.emit()

func get_hint_pair(require_stock: bool = true) -> Array:
	if current_order.is_empty():
		return []

	var names = ingredients.keys()
	var best: Array = []
	var best_score: int = 0
	var found := false

	for i in range(names.size()):
		for j in range(i, names.size()):
			if require_stock and (get_amount(names[i]) <= 0 or (i == j and get_amount(names[i]) < 2) or (i != j and get_amount(names[j]) <= 0)):
				continue

			var a = ingredients[names[i]]
			var b = ingredients[names[j]]
			var sw = a.sweetness + b.sweetness
			var co = a.coolness + b.coolness
			var fz = a.fizziness + b.fizziness

			if sw >= current_order.sweetness and co >= current_order.coolness and fz >= current_order.fizziness:
				var excess = (sw - current_order.sweetness) + (co - current_order.coolness) + (fz - current_order.fizziness)

				if not found or excess < best_score:
					found = true
					best_score = excess
					best = [names[i], names[j]]

	return best
