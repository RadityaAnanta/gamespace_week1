class_name Player2D
extends CharacterBody2D

@onready var bullet_spawn = $BulletSpawn
@export var animation: AnimatedSprite2D = null
@export var gem_label: Label = null

@export var max_health: int = 5
var health: int
@export var health_bar: ProgressBar

@export_group("Player Data")
@export var move_speed: float = 200
@export var jump_force: float = 400
@export var friction: float = 20
@export var acceleration: float = 25

@export_group("Movement Multiplier")
@export var gravity_mult: float = 1
@export var speed_mult: float = 1
@export var jump_mult : float = 1

@export_group("Movement Feel")
@export var coyote_time: float = 0.15
@export var jump_buffer: float = 0.15

@export_group("Wall Jump")
@export var wall_jump_force: float = 350
@export var wall_push_force: float = 250
@export var wall_slide_speed: float = 100
@export var wall_jump_height_mult: float = 1.4

var gems: int = 0
var bullet_scene = preload("res://week3 -/bullet.tscn")

var _direction: float = 0
var facing_direction: int = 1   # 🔥 FIX

var _coyote_timer: float = 0
var _jump_buffer_timer: float = 0
var _wall_direction: float = 0

var invincible = false

func _ready():
	update_gem_ui()

	health = max_health
	update_health_ui()


func _process(_delta: float) -> void:
	_animation()
	
	if Input.is_action_just_pressed("shoot"):
		shoot()


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_mult
		_coyote_timer -= delta
	else:
		_coyote_timer = coyote_time

	if is_on_wall() and not is_on_floor():
		_wall_direction = get_wall_normal().x

		if velocity.y > wall_slide_speed:
			velocity.y = wall_slide_speed
	else:
		_wall_direction = 0

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer

	_jump_buffer_timer -= delta

	_jump()
	_move()

	move_and_slide()


func _move() -> void:

	_direction = Input.get_axis("left", "right")

	if _direction != 0:
		facing_direction = _direction   # 🔥 SIMPAN ARAH TERAKHIR

		velocity.x = move_toward(
			velocity.x,
			move_speed * _direction * speed_mult,
			acceleration
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			friction
		)


func _jump() -> void:

	if _jump_buffer_timer > 0 and _coyote_timer > 0:
		velocity.y = -jump_force * jump_mult
		_jump_buffer_timer = 0
		_coyote_timer = 0

	elif _jump_buffer_timer > 0 and _wall_direction != 0:
		velocity.y = -wall_jump_force * wall_jump_height_mult
		velocity.x = wall_push_force * _wall_direction
		_jump_buffer_timer = 0


func _animation() -> void:

	if is_on_floor():
		if _direction != 0:
			animation.play("Move")
		else:
			animation.play("Idle")
	else:
		if velocity.y > 0:
			animation.play("Fall")
		elif velocity.y < 0:
			animation.play("Jump")

	_facing_direction()


func _facing_direction() -> void:

	if facing_direction > 0:
		animation.flip_h = false
		bullet_spawn.position.x = abs(bullet_spawn.position.x)
	else:
		animation.flip_h = true
		bullet_spawn.position.x = -abs(bullet_spawn.position.x)


func shoot():

	print("Triple Shoot FIX")

	var spacing = 30

	for i in range(3):

		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)

		bullet.direction = facing_direction   # 🔥 FIX

		var spawn_pos = bullet_spawn.global_position
		spawn_pos.x += facing_direction * i * spacing

		bullet.global_position = spawn_pos


func add_gem(amount):
	gems += amount
	update_gem_ui()


func update_gem_ui():
	if gem_label != null:
		gem_label.text = "Gems: " + str(gems)


func update_health_ui():
	if health_bar != null:
		health_bar.value = health


func take_damage(amount):

	if invincible:
		return

	invincible = true

	health -= amount
	print("HP:", health)

	update_health_ui()

	if health <= 0:
		die()

	await get_tree().create_timer(0.5).timeout
	invincible = false


func die():
	print("Player mati")
	queue_free()
