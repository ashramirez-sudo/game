extends Node2D

@export var speed: float = 300.0
var expected_time: float = 0.0

func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y > 800:
		queue_free()
