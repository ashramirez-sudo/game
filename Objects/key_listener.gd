extends Sprite2D

@onready var falling_key = preload("res://Objects/falling_key.tscn")
@onready var score_text = preload("res://Objects/score_press_text.tscn")
@export var key_name: String = ""
@onready var hit_sound = $HitSound


var fall_key_queue = []

# If distance_from_pass is less than threshold, give that score
var perfect_press_threshold: float = 30
var great_press_threshold: float = 50
var good_press_threshold: float = 60
var ok_press_threshold: float = 80

var perfect_press_score: float = 250
var great_press_score: float = 100
var good_press_score: float = 50
var ok_press_score: float = 20

func _ready():
	if has_node("GlowOverlay"):
		$GlowOverlay.frame = frame + 4
	Signals.CreateFallingKey.connect(CreateFallingKey)

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	
	if Input.is_action_just_pressed(key_name):
		Signals.KeyListenerPress.emit(key_name, frame)
	
	while fall_key_queue.size() > 0 and not is_instance_valid(fall_key_queue.front()):
		fall_key_queue.pop_front()

	if fall_key_queue.size() > 0 and is_instance_valid(fall_key_queue.front()):
		if fall_key_queue.front().has_passed:
			var passed_key = fall_key_queue.pop_front()
			if is_instance_valid(passed_key):
				passed_key.queue_free()
				
			# PRINT MISS
			var st_inst = score_text.instantiate()
			get_tree().get_root().call_deferred("add_child", st_inst)
			st_inst.SetTextInfo("MISS")
			st_inst.global_position = global_position + Vector2(0, -15)
			Signals.ResetCombo.emit()
			Signals.NoteHit.emit("MISS")

	# If key is pressed, pop from queue and calculate score
	if Input.is_action_just_pressed(key_name) and fall_key_queue.size() > 0:
		var key_to_pop = fall_key_queue.pop_front()
		if is_instance_valid(key_to_pop):
			var distance_from_pass = abs(global_position.y - key_to_pop.global_position.y)
			
			if has_node("AnimationPlayer"):
				$AnimationPlayer.stop()
				$AnimationPlayer.play("key_hit")
				hit_sound.play()
			
			var press_score_text: String = ""
			if distance_from_pass < perfect_press_threshold:
				Signals.IncrementScore.emit(int(perfect_press_score))
				press_score_text = "PERFECT"
				Signals.IncrementCombo.emit()
			elif distance_from_pass < great_press_threshold:
				Signals.IncrementScore.emit(int(great_press_score))
				press_score_text = "GREAT"
				Signals.IncrementCombo.emit()
			elif distance_from_pass < good_press_threshold:
				Signals.IncrementScore.emit(int(good_press_score))
				press_score_text = "GOOD"
				Signals.IncrementCombo.emit()
			elif distance_from_pass < ok_press_threshold:
				Signals.IncrementScore.emit(int(ok_press_score))
				press_score_text = "OK"
				Signals.IncrementCombo.emit()
			else:
				press_score_text = "MISS"
				Signals.ResetCombo.emit()
			
			Signals.NoteHit.emit(press_score_text)
			key_to_pop.queue_free()
			
			var st_inst = score_text.instantiate()
			get_tree().get_root().call_deferred("add_child", st_inst)
			st_inst.SetTextInfo(press_score_text)
			st_inst.global_position = global_position + Vector2(0, -15)
	
	
	

func CreateFallingKey(button_name: String, speed: float = 0.0):
	if button_name == key_name:
		var fk_inst = falling_key.instantiate()
		fk_inst.speed = speed 
		get_tree().get_root().call_deferred("add_child", fk_inst)
		fk_inst.Setup(position.x, frame + 4)
		fall_key_queue.push_back(fk_inst)

func _on_random_spawn_timer_timeout():
	#CreateFallingKey()
	$RandomSpawnTimer.wait_time = randf_range(0.4, 3)
	$RandomSpawnTimer.start()
