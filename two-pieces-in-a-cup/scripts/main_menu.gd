extends Node2D

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	SceneTransition.change_scene("res://scenes/main.tscn")
