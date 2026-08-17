extends TextureRect

enum State { EMPTY, SEEDED, WATERED }

var state: State = State.EMPTY

@onready var seeded: TextureRect = $seeded
@onready var watered: TextureRect = $watered
@onready var plant_texture: TextureRect = $plant


func _ready() -> void:
	add_to_group("plots")
	update_visual()


func plant_seed() -> void:
	if state != State.EMPTY:
		return
	
	state = State.SEEDED
	update_visual()


func plant() -> void:
	plant_seed()


func water() -> void:
	if state != State.SEEDED:
		return
	
	state = State.WATERED
	update_visual()


func update_visual() -> void:
	seeded.visible = state == State.SEEDED
	watered.visible = state == State.WATERED
	plant_texture.visible = false
