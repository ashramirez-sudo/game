extends Node2D

@onready var music_player = $music

var _chart_data: Array = []
var _spawn_queues: Array = [[], [], [], []]
var _lane_buttons: Array = ["button_D", "button_F", "button_J", "button_K"]

var _is_finishing: bool = false

func _ready():
	_is_finishing = false
	if has_node("LevelEditor"):
		$LevelEditor.queue_free()

	_chart_data = SongManager.get_selected_chart_data()
	print("Loaded Chart Data: ", _chart_data) # Debug print
	
	_spawn_queues = [[], [], [], []]
	if typeof(_chart_data) == TYPE_ARRAY and _chart_data.size() >= 4:
		for i in range(4):
			if typeof(_chart_data[i]) == TYPE_ARRAY:
				_spawn_queues[i] = _chart_data[i].duplicate()
				_spawn_queues[i].sort()
				print("Populated Queues: ", _spawn_queues) # Debug print

	var stream = SongManager.get_selected_song_stream()
	if stream:
		music_player.stream = stream
		music_player.play()

func _process(_delta):
	if not is_instance_valid(music_player) or not music_player.playing:
		return
		
	var song_pos = music_player.get_playback_position()
	
	var current_speed = SongManager.get_fall_speed_for_difficulty()
	var spawn_delay = 2.0
	
	for lane in range(4):
		var queue = _spawn_queues[lane]
		var button_name = _lane_buttons[lane]
		while queue.size() > 0 and song_pos >= (queue[0] - spawn_delay):
			queue.pop_front()
			
			Signals.CreateFallingKey.emit(button_name, current_speed)

func _on_music_finished():
	if _is_finishing:
		return
	_is_finishing = true
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/ending_scene.tscn")
