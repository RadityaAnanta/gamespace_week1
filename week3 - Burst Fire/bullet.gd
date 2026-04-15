extends CharacterBody2D

@export var speed: float = 500
var direction: int = 1

var has_hit = false   # 🔥 penting

func _physics_process(delta):

	if has_hit:
		return   # sudah kena → stop total

	velocity.x = direction * speed
	move_and_slide()

	for i in range(get_slide_collision_count()):

		var collision = get_slide_collision(i)
		var body = collision.get_collider()

		if body is Enemy:

			has_hit = true   # 🔥 tandai sudah kena

			body.take_damage(1)

			# 🔥 MATIKAN collision biar tidak kena lagi
			set_collision_layer(0)
			set_collision_mask(0)

			queue_free()
			return

		# kena tembok
		has_hit = true
		set_collision_layer(0)
		set_collision_mask(0)

		queue_free()
		return
