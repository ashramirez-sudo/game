extends Control

@onready var header_label = %HeaderLabel if has_node("%HeaderLabel") else null
@onready var song_info_label = %SongInfoLabel if has_node("%SongInfoLabel") else null
@onready var grade_label = %GradeLabel if has_node("%GradeLabel") else null
@onready var stats_label = %StatsLabel if has_node("%StatsLabel") else null
@onready var judgments_label = %JudgmentsLabel if has_node("%JudgmentsLabel") else null

func _ready() -> void:
	var final_acc: float = Signals.final_accuracy
	var final_score: int = Signals.final_score
	var max_combo: int = Signals.max_combo

	var song = SongManager.get_selected_song()
	var song_title = song.get("title", "Unknown Title")
	var song_artist = song.get("artist", "")
	var diff = song.get("difficulty", "Normal")

	if song_info_label:
		if song_artist != "" and song_artist != "Unknown Artist":
			song_info_label.text = "%s - %s  [%s]" % [song_artist, song_title, diff]
		else:
			song_info_label.text = "%s  [%s]" % [song_title, diff]

	if stats_label:
		stats_label.text = "Score: %d pts\nAccuracy: %.2f%%\nMax Combo: %dx" % [final_score, final_acc, max_combo]

	if judgments_label:
		judgments_label.text = "Perfect: %d | Great: %d | Good: %d | OK: %d | Miss: %d" % [
			Signals.perfect_count, Signals.great_count, Signals.good_count, Signals.ok_count, Signals.miss_count
		]

	var rank_text = "D"
	var rank_color = Color("888888")

	if final_acc >= 95.0:
		rank_text = "S"
		rank_color = Color("ffbe00")
	elif final_acc >= 90.0:
		rank_text = "A"
		rank_color = Color("e2dd25")
	elif final_acc >= 80.0:
		rank_text = "B"
		rank_color = Color("a7dd25")
	elif final_acc >= 70.0:
		rank_text = "C"
		rank_color = Color("8dbfc7")
	else:
		rank_text = "D"
		rank_color = Color("888888")

	if grade_label:
		grade_label.text = rank_text
		grade_label.add_theme_color_override("font_color", rank_color)

func _on_retry_button_pressed() -> void:
	var map_scene = SongManager.get_selected_map_scene()
	if map_scene:
		get_tree().change_scene_to_packed(map_scene)
	else:
		get_tree().change_scene_to_file("res://levels/game_level.tscn")

func _on_retry_pressed() -> void:
	_on_retry_button_pressed()

func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/song_select_menu.tscn")
