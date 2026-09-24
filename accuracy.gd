extends Control

var total_notes: int = 0
var earned_points: float = 0.0

func _ready():
	Signals.NoteHit.connect(_on_note_hit)
	text = "Accuracy: 100.00%"

func _on_note_hit(judgment: String):
	total_notes += 1
	
	# Add points based on the judgment string passed by the signal
	match judgment:
		"PERFECT":
			earned_points += 1.0
		"GREAT":
			earned_points += 0.8
		"GOOD":
			earned_points += 0.5
		"OK":
			earned_points += 0.2
		"MISS":
			earned_points += 0.0
			
	# Calculate the percentage
	var current_accuracy = (earned_points / float(total_notes)) * 100.0
	
	text = "Accuracy: 100.00" % current_accuracy
