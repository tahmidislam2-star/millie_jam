extends Node

var min_pos := Vector2.ZERO
var max_pos := Vector2.ZERO

func set_bounds(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> void:
	var xs = [a.x, b.x, c.x, d.x]
	var ys = [a.y, b.y, c.y, d.y]
	min_pos = Vector2(xs.min(), ys.min())
	max_pos = Vector2(xs.max(), ys.max())

func clamp_point(p: Vector2) -> Vector2:
	return Vector2(clamp(p.x, min_pos.x, max_pos.x), clamp(p.y, min_pos.y, max_pos.y))
