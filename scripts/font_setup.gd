extends Node

var game_font: Font


func _ready() -> void:
	game_font = ThemeDB.fallback_font
	var theme := Theme.new()
	theme.default_font = ThemeDB.fallback_font
	theme.default_font_size = 16
	get_tree().root.theme = theme
