extends TextureButton

@export var price: int = 500
@export var item_type: String = "dress" 
@export var dress_texture: Texture2D   
@export var normal_color := Color.WHITE
@export var hover_color := Color(1.2, 1.2, 1.2)
@export var equipped_color := Color(0.55, 0.55, 0.55)

@onready var coin_label: Label = $coin_label
@onready var buy_sound: AudioStreamPlayer = $"../../../../buy_sound"

var owned := false
var equipped := false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)
	coin_label.text = str(price)

func _on_mouse_entered() -> void:
	create_tween().tween_property(self, "modulate", hover_color, 0.08)

func _on_mouse_exited() -> void:
	var base_color = equipped_color if equipped else normal_color
	create_tween().tween_property(self, "modulate", base_color, 0.08)

func _on_pressed() -> void:
	if not owned:
		_try_purchase()
	else:
		_toggle_equip()

func _try_purchase() -> void:
	if Wardrobe.spend(price):
		owned = true
		equipped = true
		coin_label.text = "Equipped"
		buy_sound.play()
		modulate = equipped_color
		Wardrobe.equip(item_type, dress_texture, self)
	

func _toggle_equip() -> void:
	equipped = !equipped
	if equipped:
		coin_label.text = "Equipped"
		modulate = equipped_color
		Wardrobe.equip(item_type, dress_texture, self)
	else:
		coin_label.text = "Owned"
		modulate = normal_color
		Wardrobe.unequip(item_type)

func force_unequip() -> void:
	equipped = false
	coin_label.text = "Owned"
	modulate = normal_color
