extends Control

func _ready():
	visible = false
	Signals.GameOver.connect(_on_game_over)

func _on_game_over():
	get_tree().paused = true
	visible = true

func _on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/song_select_menu.tscn")
