extends Control

@onready var song_list_container = %SongListContainer
@onready var preview_player = %PreviewPlayer
@onready var current_title_label = %CurrentTitleLabel
@onready var current_artist_label = %CurrentArtistLabel
@onready var current_diff_label = %CurrentDiffLabel

var song_card_scene = preload("res://levels/song_card.tscn")

func _ready():
	SongManager.scan_music_and_generate_charts()
	populate_song_list()
	var default_id = SongManager.selected_song_id
	if default_id == "":
		default_id = "cloud_9"
	_on_song_card_selected(default_id)

func populate_song_list():
	for child in song_list_container.get_children():
		child.queue_free()

	var sorted_ids = SongManager.get_sorted_song_ids()
	for song_id in sorted_ids:
		var card = song_card_scene.instantiate()
		song_list_container.add_child(card)
		card.setup(song_id, SongManager.songs[song_id])
		card.song_selected.connect(_on_song_card_selected)

func _on_song_card_selected(song_id: String):
	SongManager.select_song(song_id)
	var song_info = SongManager.get_selected_song()
	
	for child in song_list_container.get_children():
		if child.has_method("set_selected"):
			child.set_selected(child.song_id == song_id)
	
	if current_title_label:
		current_title_label.text = song_info.get("title", "")
	if current_artist_label:
		current_artist_label.text = "Artist: " + song_info.get("artist", "")
	if current_diff_label:
		current_diff_label.text = "Difficulty: " + song_info.get("difficulty", "")

	var stream = SongManager.get_selected_song_stream()
	if preview_player.playing:
		preview_player.stop()
	if stream:
		preview_player.stream = stream
		preview_player.play(5.0)

func _on_play_button_pressed():
	if preview_player.playing:
		preview_player.stop()
	var map_scene = SongManager.get_selected_map_scene()
	if map_scene:
		get_tree().change_scene_to_packed(map_scene)
	else:
		get_tree().change_scene_to_file("res://levels/game_level.tscn")

func _on_back_button_pressed():
	if preview_player.playing:
		preview_player.stop()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_edit_button_pressed():
	GlobalState.in_edit_mode = true
	GlobalState.current_level_name = SongManager.selected_song_id
	get_tree().change_scene_to_file("res://levels/game_level.tscn")
