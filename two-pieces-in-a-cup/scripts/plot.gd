extends Control

signal harvested(plant_name: String)

enum State { EMPTY, SEEDED, WATERED, GROWN }

@onready var plant: TextureRect = $plant
@onready var seeded: TextureRect = $seeded
@onready var watered: TextureRect = $watered

var state: State = State.EMPTY
var plant_type: String = ""

func _ready() -> void:
	add_to_group("plots")
	plant.visible = false
	seeded.visible = false
	watered.visible = false
	plant.mouse_filter = Control.MOUSE_FILTER_STOP
	plant.gui_input.connect(_on_plant_gui_input)

func can_plant() -> bool:
	return state == State.EMPTY

func plant_seed(type_name: String) -> void:
	plant_type = type_name
	state = State.SEEDED
	seeded.visible = true
	watered.visible = false
	plant.visible = false

func water() -> void:
	if state == State.SEEDED:
		state = State.WATERED
		watered.visible = true
		seeded.visible = false

func grow() -> void:
	if state == State.WATERED:
		state = State.GROWN
		plant.texture = FarmStand.plant_types[plant_type].tree_texture
		plant.visible = true
		watered.visible = false

func _on_plant_gui_input(event: InputEvent) -> void:
	if state != State.GROWN:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_harvest()

func _harvest() -> void:
	FarmStand.add_harvest(plant_type, 1)
	harvested.emit(plant_type)
	state = State.EMPTY
	plant_type = ""
	plant.visible = false
	seeded.visible = false
	watered.visible = false
