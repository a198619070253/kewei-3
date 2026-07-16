extends Node2D

var path_points: PackedVector2Array = PackedVector2Array([
	Vector2(60, 360),
	Vector2(180, 360),
	Vector2(180, 140),
	Vector2(520, 140),
	Vector2(520, 520),
	Vector2(880, 520),
	Vector2(880, 220),
	Vector2(1100, 220),
	Vector2(1100, 360),
	Vector2(1240, 360),
])

const BASE_POS := Vector2(1240, 360)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	_draw_background()
	_draw_path()
	_draw_base_pagoda()


func _draw_background() -> void:
	var size := get_viewport().get_visible_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.15, 0.22, 0.14))
	for x in range(0, int(size.x), 48):
		for y in range(0, int(size.y), 48):
			var shade := 0.02 if (x / 48 + y / 48) % 2 == 0 else 0.0
			draw_rect(Rect2(x, y, 48, 48), Color(0.15 + shade, 0.22 + shade, 0.14 + shade))


func _draw_path() -> void:
	if path_points.size() < 2:
		return
	for i in range(path_points.size() - 1):
		draw_line(path_points[i], path_points[i + 1], Color(0.55, 0.42, 0.28), 36.0)
		draw_line(path_points[i], path_points[i + 1], Color(0.65, 0.52, 0.35), 28.0)
	draw_circle(path_points[0], 20.0, Color(0.8, 0.3, 0.3, 0.6))
	draw_string(ThemeDB.fallback_font, path_points[0] + Vector2(-18, -28), "敌营", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 0.7, 0.7))


func _draw_base_pagoda() -> void:
	_draw_pagoda(BASE_POS, 6, Color(0.85, 0.65, 0.2), true)
	draw_string(ThemeDB.fallback_font, BASE_POS + Vector2(-24, 58), "主宝塔", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 0.9, 0.5))


func _draw_pagoda(pos: Vector2, levels: int, color: Color, is_base: bool = false) -> void:
	var base_w := 28.0 if is_base else 18.0
	for i in range(levels):
		var floor_y := pos.y - float(i) * (22.0 if is_base else 16.0)
		var shrink := float(i) * (2.5 if is_base else 2.0)
		var hw := base_w - shrink
		var body_color := color.lerp(Color(0.9, 0.5, 0.15), float(i) / float(levels))
		draw_rect(Rect2(pos.x - hw, floor_y - 18.0, hw * 2.0, 18.0), body_color)
		draw_rect(Rect2(pos.x - hw, floor_y - 18.0, hw * 2.0, 18.0), body_color.darkened(0.25), false, 1.5)
		var roof_w := hw + 6.0
		var roof := PackedVector2Array([
			Vector2(pos.x - roof_w, floor_y - 18.0),
			Vector2(pos.x + roof_w, floor_y - 18.0),
			Vector2(pos.x, floor_y - 30.0),
		])
		draw_colored_polygon(roof, body_color.darkened(0.35))
		draw_polyline(roof, Color(0.2, 0.1, 0.05, 0.5), 1.0, true)
