extends Node2D


func _ready() -> void:
	call_deferred("_init_game")


func _init_game() -> void:
	GameManager.setup(self)


func rebuild_build_slots(slot_positions: Array) -> void:
	for child in $BuildSlots.get_children():
		child.queue_free()
	var slot_scene := preload("res://scenes/build_slot.tscn")
	for pos in slot_positions:
		var slot := slot_scene.instantiate()
		slot.global_position = pos
		$BuildSlots.add_child(slot)
