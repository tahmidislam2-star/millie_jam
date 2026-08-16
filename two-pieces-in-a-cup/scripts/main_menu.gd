extends Node2D

@onready var start_button: Button = $Control/start

var start_pressed: bool = false

func _ready() -> void:
	start_button.toggle_mode = true

func _on_start_pressed() -> void:
	if start_pressed == false:
		start_pressed = true
		start_button.button_pressed = true
		start_button.disabled = true
		SceneTransition.change_scene("res://scenes/main.tscn")
