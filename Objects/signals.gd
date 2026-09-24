extends Node2D

@warning_ignore("unused_signal")
signal IncrementScore(incr: int)

@warning_ignore("unused_signal")
signal IncrementCombo()
@warning_ignore("unused_signal")
signal ResetCombo()

@warning_ignore("unused_signal")
signal CreateFallingKey(button_name: String)
@warning_ignore("unused_signal")
signal KeyListenerPress(button_name: String, array_num: int)

@warning_ignore("unused_signal")
signal NoteHit(rating: String)

@warning_ignore("unused_signal")
signal GameOver()

var final_accuracy: float = 100.0
var final_score: int = 0
var max_combo: int = 0
var perfect_count: int = 0
var great_count: int = 0
var good_count: int = 0
var ok_count: int = 0
var miss_count: int = 0

func reset_stats() -> void:
	final_accuracy = 100.0
	final_score = 0
	max_combo = 0
	perfect_count = 0
	great_count = 0
	good_count = 0
	ok_count = 0
	miss_count = 0
