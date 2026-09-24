extends Control

func _ready():
	$AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("esc") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()


func _on_resume_pressed():
	resume()


func _on_restart_pressed():
	resume()
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/song_select_menu.tscn")

@warning_ignore("unused_parameter")
func _process(_delta):
	testEsc()


func _on_reset_audio_pressed():
	AudioServer.output_device = "Default"

func populate_audio_dropdown():
	@warning_ignore("unused_variable")
	var available_devices = AudioServer.get_output_device_list()

func set_new_audio_device(device_name: String):
	AudioServer.output_device = device_name
