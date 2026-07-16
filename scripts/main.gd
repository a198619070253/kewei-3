extends Node2D


func _ready() -> void:
	call_deferred("_init_game")


func _init_game() -> void:
	GameManager.setup(self)
	_setup_build_slots()


func _setup_build_slots() -> void:
	var slots := [
		Vector2(120, 280), Vector2(120, 440),
		Vector2(260, 80), Vector2(260, 220),
		Vector2(400, 80), Vector2(400, 220),
		Vector2(460, 420), Vector2(460, 560),
		Vector2(640, 420), Vector2(640, 560),
		Vector2(780, 420), Vector2(780, 560),
		Vector2(720, 80), Vector2(720, 160),
		Vector2(960, 80), Vector2(960, 160),
		Vector2(960, 300), Vector2(960, 440),
		Vector2(1040, 300), Vector2(1040, 440),
	]
	var slot_scene := preload("res://scenes/build_slot.tscn")
	for pos in slots:
		var slot := slot_scene.instantiate()
		slot.global_position = pos
		$BuildSlots.add_child(slot)
