extends Node

signal seeds_changed(plant_name: String)

var plant_types: Dictionary = {} 
var seeds: Dictionary = {}     
var seed_icon_texture: Texture2D  

func register_plant(plant_name: String, tree_texture: Texture2D, starting_seeds: int) -> void:
	plant_types[plant_name] = {"tree_texture": tree_texture}
	if not seeds.has(plant_name):
		seeds[plant_name] = starting_seeds

func get_seed_count(plant_name: String) -> int:
	return seeds.get(plant_name, 0)

func has_seed(plant_name: String) -> bool:
	return get_seed_count(plant_name) > 0

func use_seed(plant_name: String) -> void:
	seeds[plant_name] = get_seed_count(plant_name) - 1
	seeds_changed.emit(plant_name)

func add_harvest(plant_name: String, amount: int = 1) -> void:
	if DrinkStand.ingredients.has(plant_name):
		DrinkStand.add_ingredient_stock(plant_name, amount)
	
