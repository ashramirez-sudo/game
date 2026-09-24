extends Control

var score: int = 0
var combo_count: int = 0

var total_notes: int = 0
var earned_points: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.reset_stats()
	Signals.IncrementScore.connect(IncrementScore)
	Signals.IncrementCombo.connect(IncrementCombo)
	Signals.ResetCombo.connect(ResetCombo)
	
	Signals.NoteHit.connect(_on_note_hit)
	
	ResetCombo()
	
	%AccuracyLabel.text = "Accuracy: 100.00%"

func IncrementScore(incr: int):
	score += incr
	%ScoreLabel.text = " " + str(score) + " pts"
	Signals.final_score = score

func IncrementCombo():
	combo_count += 1
	%ComboLabel.text = " " + str(combo_count) + "x combo"
	if combo_count > Signals.max_combo:
		Signals.max_combo = combo_count

func ResetCombo():
	combo_count = 0
	%ComboLabel.text = ""

func _on_note_hit(judgment: String):
	total_notes += 1
	
	match judgment:
		"PERFECT":
			earned_points += 1.0
			Signals.perfect_count += 1
		"GREAT":
			earned_points += 0.8
			Signals.great_count += 1
		"GOOD":
			earned_points += 0.5
			Signals.good_count += 1
		"OK":
			earned_points += 0.2
			Signals.ok_count += 1
		"MISS":
			earned_points += 0.0
			Signals.miss_count += 1
			
	var current_accuracy = (earned_points / float(total_notes)) * 100.0
	Signals.final_accuracy = current_accuracy
	%AccuracyLabel.text = "Accuracy: %.2f%%" % current_accuracy
