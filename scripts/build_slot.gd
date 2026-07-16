extends Area2D

var has_tower := false
var tower: Node2D = null

const TOWER_SCENE := preload("res://scenes/pagoda_tower.tscn")


func _ready() -> void:
	input_pickable = true
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	queue_redraw()


func _draw() -> void:
	var color := Color(0.3, 0.55, 0.3, 0.35) if not has_tower else Color(0.5, 0.4, 0.2, 0.2)
	draw_circle(Vector2.ZERO, 28.0, color)
	draw_arc(Vector2.ZERO, 28.0, 0, TAU, 32, Color(0.4, 0.65, 0.4, 0.5), 1.5, true)
	if not has_tower:
		draw_line(Vector2(-10, 0), Vector2(10, 0), Color(0.5, 0.8, 0.5, 0.7), 2.0)
		draw_line(Vector2(0, -10), Vector2(0, 10), Color(0.5, 0.8, 0.5, 0.7), 2.0)


func _on_mouse_entered() -> void:
	if not has_tower:
		modulate = Color(1.2, 1.2, 1.2)
	queue_redraw()


func _on_mouse_exited() -> void:
	modulate = Color.WHITE
	queue_redraw()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not GameManager.game_running or GameManager.game_over:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if has_tower:
			_try_upgrade()
		else:
			_try_build()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if has_tower:
			_show_info()


func _try_build() -> void:
	var type: int = GameManager.selected_tower_type
	if type < 0:
		return
	var cost: int = GameManager.TOWER_COSTS.get(type, 9999)
	if not GameManager.can_afford(type):
		return
	if not GameManager.spend_gold(cost):
		return

	var new_tower := TOWER_SCENE.instantiate()
	new_tower.global_position = global_position
	new_tower.setup(type)
	get_tree().current_scene.get_node("Towers").add_child(new_tower)
	tower = new_tower
	has_tower = true
	queue_redraw()


func _try_upgrade() -> void:
	if tower and tower.has_method("upgrade"):
		tower.upgrade()


func _show_info() -> void:
	pass
