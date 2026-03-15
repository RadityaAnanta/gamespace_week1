extends Area2D

var value = 10

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if body is Player2D:
		body.add_gem(value)
		queue_free()
