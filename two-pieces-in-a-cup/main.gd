extends Node2D
@onready var dress: Sprite2D = $bedroom/dress
@onready var glass: Sprite2D = $bedroom/glass
@onready var hat: Sprite2D = $bedroom/hat

@onready var dresses: MarginContainer = $bedroom/dresses
@onready var dresses_container: MarginContainer = $bedroom/dresses
@onready var hats_container: MarginContainer = $bedroom/hats
@onready var glasses_container: MarginContainer = $bedroom/glasses
@onready var coin_label: Label = $CanvasLayer/coin_label

var slot_sprites := {}

func _ready() -> void:
	slot_sprites = {"dress": dress, "glass": glass, "hat": hat}
	Wardrobe.item_equipped.connect(_on_item_equipped)
	Wardrobe.item_unequipped.connect(_on_item_unequipped)
	Wardrobe.coins_changed.connect(_on_coins_changed)
	coin_label.text = str(Wardrobe.coins)

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
