extends ProgressBar
class_name HealthBarUI

@export var max_hp: float = 100.0
var hp: float = 100.0

func _ready():
	max_value = max_hp
	hp = max_hp
	value = hp
	
	Signals.NoteHit.connect(_on_note_hit)

func _on_note_hit(rating: String):
	match rating:
		"PERFECT":
			modify_health(20.0)
		"GREAT":
			modify_health(15.0)
		"GOOD":
			modify_health(10.0)
		"OK":
			modify_health(5.0)
		"MISS":
			modify_health(-5.0)

func modify_health(percent: float):
	var change = (percent / 100.0) * max_hp
	hp = clamp(hp + change, 0.0, max_hp)
	value = hp
	if hp <= 0.0:
		Signals.GameOver.emit()
