extends Button

signal song_selected(song_id: String)

var song_id: String = ""

@onready var title_label = $MarginContainer/HBoxContainer/VBoxContainer/TitleLabel
@onready var artist_label = $MarginContainer/HBoxContainer/VBoxContainer/ArtistLabel
@onready var difficulty_label = $MarginContainer/HBoxContainer/DifficultyLabel

func setup(id: String, song_info: Dictionary):
	song_id = id
	title_label.text = song_info.get("title", "Unknown Title")
	artist_label.text = song_info.get("artist", "Unknown Artist")
	
	var diff = song_info.get("difficulty", "Normal")
	difficulty_label.text = diff
	
	match diff:
		"Easy":
			difficulty_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4))
		"Normal":
			difficulty_label.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
		"Hard":
			difficulty_label.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
		"Expert":
			difficulty_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.3))

func set_selected(is_sel: bool):
	if is_sel:
		modulate = Color(1.25, 1.25, 0.75)
	else:
		modulate = Color(1.0, 1.0, 1.0)

func _on_pressed():
	song_selected.emit(song_id)
