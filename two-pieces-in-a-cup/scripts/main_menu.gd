extends Node2D

@onready var start_button: Button = $Control/start
@onready var turorial: Button = $Control/Turorial
@onready var click: AudioStreamPlayer = $click

var start_pressed: bool = false
var tut_pressed = false

func _ready() -> void:
	start_button.toggle_mode = true

func _on_start_pressed() -> void:
	if start_pressed == false and tut_pressed!= true:
		click.play()
		start_pressed = true
		start_button.button_pressed = true
		start_button.disabled = true
		SceneTransition.change_scene("res://scenes/main.tscn")


func _on_turorial_pressed() -> void:
	if tut_pressed == false and start_pressed != true:
		click.play()
		tut_pressed = true
		turorial.button_pressed = true
		turorial.disabled = true
		SceneTransition.change_scene("res://scenes/tutorial.tscn")
