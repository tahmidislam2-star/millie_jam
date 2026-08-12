extends Node

signal coins_changed(new_amount: int)
signal item_equipped(item_type: String, texture: Texture2D)
signal item_unequipped(item_type: String)

var coins: int = 1000
var equipped: Dictionary = {}

func can_afford(price: int) -> bool:
	return coins >= price

func spend(price: int) -> bool:
	if not can_afford(price):
		return false
	coins -= price
	coins_changed.emit(coins)
	return true

func equip(item_type: String, texture: Texture2D, button: Node) -> void:
	if equipped.has(item_type) and equipped[item_type] != button:
		equipped[item_type].force_unequip()
	equipped[item_type] = button
	item_equipped.emit(item_type, texture)

func unequip(item_type: String) -> void:
	equipped.erase(item_type)
	item_unequipped.emit(item_type)
