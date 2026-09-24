extends Node

var songs: Dictionary = {
	"cloud_9": {
		"title": "Cloud 9",
		"artist": "Tobu & Itro",
		"difficulty": "Easy",
		"path": "res://music/Tobu Itro - Cloud 9.mp3",
		"chart": "res://charts/cloud_9.json"
	},
	"rumors": {
		"title": "Rumors (Nightcore)",
		"artist": "Nightcore",
		"difficulty": "Hard",
		"path": "res://music/Nightcore - Rumors But it hits different Lyrics.mp3",
		"chart": "res://charts/rumors.json"
	},
	"stolen_dance": {
		"title": "Stolen Dance (Remix)",
		"artist": "Milky Chance",
		"difficulty": "Normal",
		"path": "res://music/Milky Chance - Stolen Dance Phake Remix.mp3",
		"chart": "res://charts/stolen_dance.json"
	},
	"ochame_kinou": {
		"title": "Ochame Kinou",
		"artist": "Hololive",
		"difficulty": "Hard",
		"path": "res://music/おちゃめ機能ホロライブが吹っ切れた24人で歌ってみた.mp3",
		"chart": "res://charts/ochame_kinou.json"
	},
	"kaiju": {
		"title": "Kaiju (怪獣)",
		"artist": "Sakanaction",
		"difficulty": "Normal",
		"path": "res://music/サカナクション 怪獣 -Music Video-.mp3",
		"chart": "res://charts/kaiju.json"
	},
	"heavenly_jump": {
		"title": "Nightcore Heavenly Jump",
		"artist": "INNXCENCE, Sxilwix & TWXNY",
		"difficulty": "Hard",
		"path": "res://music/Nightcore - HEAVENLY JUMPSTYLE (Rock Version) (lyrics).mp3",
		"chart": "res://charts/heavenly_jump.json",
	},
	"you_&_me": {
		"title": "You & Me",
		"artist": "nikolett",
		"difficulty": "Expert",
		"path": "res://music/You & Me (feat. Nikolett).mp3",
	},
	"sweet_little_monster": {
		"title": "Sweet Little monster",
		"artist": "SatilmisNCSR",
		"difficulty": "Expert",
		"path": "res://music/Sweet Little Monster - Nightcore _ Pop Electronic Song.mp3",
		"chart": "res://charts/sweet_little_monster.json"
	}
}

var selected_song_id: String = "cloud_9"

# Map handling
var song_maps: Dictionary = {
	"cloud_9": "res://levels/game_level.tscn",
	"rumors": "res://levels/game_level.tscn",
	"stolen_dance": "res://levels/game_level.tscn",
	"ochame_kinou": "res://levels/game_level.tscn",
	"kaiju": "res://levels/game_level.tscn",
	"heavenly_jump": "res://levels/game_level.tscn",
	"sweet_little_monster": "res://levels/game_level.tscn"
}


const CHART_EDITOR_SCENE: String = "res://levels/chart_editor.tscn"

func _ready() -> void:
	scan_music_and_generate_charts()


func select_song(song_id: String) -> void:
	if songs.has(song_id):
		selected_song_id = song_id


func get_selected_song() -> Dictionary:
	if selected_song_id == "" or not songs.has(selected_song_id):
		selected_song_id = "cloud_9"
	return songs.get(selected_song_id, {})


func get_selected_song_stream() -> AudioStream:
	var song = get_selected_song()
	if song.is_empty():
		return null
	var path = song.get("path", "")
	if path == "":
		return null
	if ResourceLoader.exists(path):
		return load(path)
	return null


func get_selected_chart_data() -> Array:
	var song = get_selected_song()
	var chart_path = song.get("chart", "")
	if chart_path == "" or not FileAccess.file_exists(chart_path):
		chart_path = "res://charts/" + selected_song_id + ".json"

	if FileAccess.file_exists(chart_path):
		var file = FileAccess.open(chart_path, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(json_text)
			if parsed is Dictionary and parsed.has("fk_times") and typeof(parsed["fk_times"]) == TYPE_ARRAY:
				return parsed["fk_times"]
			elif parsed is Array:
				return parsed

	print("[SongManager] Chart missing for %s, creating blank template..." % selected_song_id)
	return ensure_chart_exists(selected_song_id)

func _difficulty_rank(diff: String) -> int:
	match diff:
		"Easy": return 1
		"Normal": return 2
		"Hard": return 3
		"Expert": return 4
		_ : return 5


func get_sorted_song_ids() -> Array:
	var ids = songs.keys()
	ids.sort_custom(func(a, b):
		var da = _difficulty_rank(songs[a].get("difficulty", ""))
		var db = _difficulty_rank(songs[b].get("difficulty", ""))
		if da == db:
			return a < b
		return da < db
	)
	return ids

func get_selected_map_path() -> String:
	return song_maps.get(selected_song_id, "res://levels/game_level.tscn")

func get_selected_map_scene() -> PackedScene:
	var path = get_selected_map_path()
	if path == "":
		return load("res://levels/game_level.tscn")
	return load(path)

func get_selected_difficulty() -> String:
	var song = get_selected_song()
	return song.get("difficulty", "Normal")

func get_fall_speed_for_difficulty(diff: String = "") -> float:
	if diff == "":
		diff = get_selected_difficulty()
	match diff:
		"Easy": return 3.0
		"Normal": return 4.8
		"Hard": return 6.5
		"Expert": return 8.5
		_: return 4.8


func scan_music_and_generate_charts() -> void:
	_ensure_directory_exists("res://charts")
	_ensure_directory_exists("res://music")

	for s_id in songs.keys():
		ensure_chart_exists(s_id)

	var dir = DirAccess.open("res://music")
	if not dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and not file_name.ends_with(".import") and not file_name.ends_with(".tmp"):
			var ext = file_name.get_extension().to_lower()
			if ext in ["wav", "mp3", "ogg"]:
				var full_path = "res://music/" + file_name
				_register_and_ensure_audio_file(full_path, file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func _register_and_ensure_audio_file(audio_path: String, file_name: String) -> String:
	for s_id in songs.keys():
		if songs[s_id].get("path", "") == audio_path:
			ensure_chart_exists(s_id)
			return s_id

	var base_name = file_name.get_basename()
	var song_id = _generate_song_id(base_name)

	var title = base_name
	var artist = "Unknown Artist"
	if " - " in base_name:
		var parts = base_name.split(" - ", true, 1)
		artist = parts[0].strip_edges()
		title = parts[1].strip_edges()

	songs[song_id] = {
		"title": title,
		"artist": artist,
		"difficulty": "Normal",
		"path": audio_path,
		"chart": "res://charts/" + song_id + ".json"
	}
	if not song_maps.has(song_id):
		song_maps[song_id] = "res://levels/game_level.tscn"

	ensure_chart_exists(song_id)
	return song_id


func create_map_and_open_editor(audio_path: String, title: String = "", artist: String = "", difficulty: String = "Normal") -> void:
	var song_id = add_song_from_audio(audio_path, title, artist, difficulty)
	select_song(song_id)
	
	
	if ResourceLoader.exists(CHART_EDITOR_SCENE):
		get_tree().change_scene_to_file(CHART_EDITOR_SCENE)
	else:
		push_warning("[SongManager] Chart editor scene not found at: " + CHART_EDITOR_SCENE)


func add_song_from_audio(audio_path: String, title: String = "", artist: String = "", difficulty: String = "Normal") -> String:
	_ensure_directory_exists("res://charts")
	var file_name = audio_path.get_file()
	var base_name = file_name.get_basename()
	var song_id = _generate_song_id(base_name)

	if title == "":
		if " - " in base_name:
			var parts = base_name.split(" - ", true, 1)
			artist = parts[0].strip_edges() if artist == "" else artist
			title = parts[1].strip_edges()
		else:
			title = base_name
	if artist == "":
		artist = "Unknown Artist"

	songs[song_id] = {
		"title": title,
		"artist": artist,
		"difficulty": difficulty,
		"path": audio_path,
		"chart": "res://charts/" + song_id + ".json"
	}
	song_maps[song_id] = "res://levels/game_level.tscn"

	
	save_chart_to_json(song_id, [[], [], [], []], "res://charts/" + song_id + ".json")
	return song_id


func ensure_chart_exists(song_id: String) -> Array:
	if not songs.has(song_id):
		return [[], [], [], []]

	var song = songs[song_id]
	var chart_path = song.get("chart", "res://charts/" + song_id + ".json")
	if chart_path == "":
		chart_path = "res://charts/" + song_id + ".json"
		song["chart"] = chart_path

	if FileAccess.file_exists(chart_path):
		var file = FileAccess.open(chart_path, FileAccess.READ)
		if file:
			var json_text = file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(json_text)
			if parsed is Dictionary and parsed.has("fk_times") and typeof(parsed["fk_times"]) == TYPE_ARRAY:
				return parsed["fk_times"]

	var empty_fk_times = [[], [], [], []]
	save_chart_to_json(song_id, empty_fk_times, chart_path)
	return empty_fk_times


func save_chart_to_json(song_id: String, fk_times: Array, target_path: String = "") -> bool:
	if target_path == "":
		target_path = "res://charts/" + song_id + ".json"

	_ensure_directory_exists("res://charts")

	var chart_data = {
		"song_id": song_id,
		"fk_times": fk_times
	}

	var json_string = JSON.stringify(chart_data, "\t")
	var file = FileAccess.open(target_path, FileAccess.WRITE)
	if not file:
		push_error("[SongManager] Failed to write chart file: " + target_path)
		return false

	file.store_string(json_string)
	file.close()

	if songs.has(song_id):
		songs[song_id]["chart"] = target_path

	return true

func _ensure_directory_exists(dir_path: String) -> void:
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

@warning_ignore("shadowed_variable_base_class")
func _generate_song_id(name: String) -> String:
	var clean = name.to_lower()
	var result = ""
	for c in clean:
		if (c >= "a" and c <= "z") or (c >= "0" and c <= "9"):
			result += c
		elif c in [" ", "-", "_", "."]:
			if result.length() > 0 and not result.ends_with("_"):
				result += "_"
	result = result.strip_edges()
	if result == "":
		result = "song_" + str(hash(name)).replace("-", "n")
	return result
