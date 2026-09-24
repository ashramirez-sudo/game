extends Control



func _ready():
	pass # Replace with function body.


func _process(_delta: float):
	pass


func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/song_select_menu.tscn")



func _on_exit_pressed():
	get_tree().quit()


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://Scenes/game_settings.tscn")
