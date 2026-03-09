class_name Player2D
extends CharacterBody2D
## Player Class
## Player class digunakan untuk mengontrol semua pergerakan dari player. 
## Mulai dari jump, move, wall jump, dll.

@export var animation: AnimatedSprite2D = null

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

var _direction: float = 0
var _coyote_timer: float = 0
var _jump_buffer_timer: float = 0
var _wall_direction: float = 0

## Fungsi Process ini digunakan untuk memproses animasi player
func _process(_delta: float) -> void:
	_animation()

## Fungsi Physics Process digunakan untuk memproses game dengan fisika
func _physics_process(delta: float) -> void:
	
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_mult
		_coyote_timer -= delta
	else:
		_coyote_timer = coyote_time
	
	# deteksi tembok
	if is_on_wall() and not is_on_floor():
		_wall_direction = get_wall_normal().x
		
		# wall slide (agar tidak jatuh terlalu cepat)
		if velocity.y > wall_slide_speed:
			velocity.y = wall_slide_speed
	else:
		_wall_direction = 0
	
	# jump buffer
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer
	
	_jump_buffer_timer -= delta
	
	_jump()
	_move()
	
	move_and_slide() ## fungsi penting untuk mengeksekusi fisika

## fungsi buatan sendiri yang mengatur move
func _move() -> void:
	_direction = Input.get_axis("left", "right")
	
	if _direction != 0:
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

## fungsi buatan sendiri yang mengatur jump
func _jump() -> void:

	# jump normal
	if _jump_buffer_timer > 0 and _coyote_timer > 0:
		velocity.y = -jump_force * jump_mult
		_jump_buffer_timer = 0
		_coyote_timer = 0

	# wall jump (loncat dari tembok lebih tinggi)
	elif _jump_buffer_timer > 0 and _wall_direction != 0:
		velocity.y = -wall_jump_force * wall_jump_height_mult
		velocity.x = wall_push_force * _wall_direction
		_jump_buffer_timer = 0

## fungsi buatan sendiri yang mengatur animasi player
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

## fungsi buatan sendiri yang mengatur arah hadap karakter
func _facing_direction() -> void:
	if _direction > 0:
		animation.flip_h = false
	elif _direction < 0:
		animation.flip_h = true
