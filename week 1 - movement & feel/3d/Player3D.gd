class_name Player3D
extends CharacterBody3D

@export_group("Movement")
@export var move_speed: float = 0
@export var accelaration: float = 0
@export var rotation_speed: float = 0	
@export var jump_force: float = 0

@export_group("Feel")
@export var coyote_time: float = 0
@export var jump_buffer_time: float = 0

@onready var cam_controller: TPPCameraController = $TPPCameraController
@onready var visual: MeshInstance3D = $Visual

var _last_movement_direction: Vector3 = Vector3.ZERO
var _gravity: float = -45
var _coyote_timer: float = 0
var _jump_buffer_timer: float = 0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		_coyote_timer -= delta
	else:
		_coyote_timer = coyote_time
	
	var raw_input := Input.get_vector("left", "right", "up", "down")
	var move_direction := cam_controller.get_forward() * raw_input.y + cam_controller.get_right() * raw_input.x 
	move_direction.y = 0
	move_direction = move_direction.normalized()
	
	var velocity_y = velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, accelaration * delta)
	velocity.y = velocity_y + _gravity * delta
	
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	
	_jump_buffer_timer -= delta

	if _jump_buffer_timer > 0 and _coyote_timer > 0:
		velocity.y = jump_force
		_jump_buffer_timer = 0
		_coyote_timer = 0
	
	move_and_slide()
	
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	visual.global_rotation.y = lerp_angle(visual.rotation.y, target_angle, rotation_speed * delta)
