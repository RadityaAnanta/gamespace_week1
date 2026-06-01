class_name Player
extends CharacterBody2D

@onready var bullet_spawn = $BulletSpawn
@onready var animation = $Animation

@export var gem_label: Label = null
@export var max_health: float = 5.0
var health: float
@export var health_bar: ProgressBar

# --- SISTEM COMBO ---
@export_group("Combo System")
@export var combo_label: Label = null
@export var combo_time_limit: float = 2.0 # Waktu sebelum combo hangus (2 detik)
var combo_count: int = 0
var _combo_timer: float = 0.0

@export_group("Player Data")
@export var move_speed: float = 300
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
var bullet_scene = preload("res://week3 - Burst Fire/bullet.tscn")
var _direction: int = 0
var facing_direction: int = 1
var _coyote_timer: float = 0
var _jump_buffer_timer: float = 0
var _wall_direction: float = 0
var invincible = false

var _current_friction: float = 20 
var standing_on_lava: bool = false
var lava_damage_interval: float = 0.2 
var lava_timer: float = 0.0

func _ready():
	update_gem_ui()
	health = max_health
	update_health_ui()
	# Sembunyikan label combo di awal
	if combo_label:
		combo_label.text = ""

func _process(delta: float) -> void:
	_animation()
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
	# --- LOGIKA TIMER COMBO ---
	if combo_count > 0:
		_combo_timer -= delta
		if _combo_timer <= 0:
			reset_combo() # Waktu habis, combo putus

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_mult
		_coyote_timer -= delta
	else:
		_coyote_timer = coyote_time
		
	_detect_ground_logic(delta)

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

func _detect_ground_logic(delta: float) -> void:
	_current_friction = friction 
	standing_on_lava = false 
	
	if is_on_floor():
		var collision_count = get_slide_collision_count()
		for i in range(collision_count):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider is TileMapLayer:
				var pos_map = collider.local_to_map(collider.to_local(collision.get_position() - collision.get_normal()))
				var tile_data = collider.get_cell_tile_data(pos_map)
				
				if tile_data:
					var nilai_licin = tile_data.get_custom_data("kelicinan")
					if nilai_licin > 0:
						_current_friction = nilai_licin
						
					var cek_lava = tile_data.get_custom_data("is_lava")
					if cek_lava == true:
						standing_on_lava = true

	if standing_on_lava:
		lava_timer += delta
		if lava_timer >= lava_damage_interval:
			take_damage(0.5) 
			lava_timer = 0.0 
	else:
		lava_timer = 0.0

func _move() -> void:
	_direction = Input.get_axis("left", "right")
	if _direction != 0:
		facing_direction = _direction   
		velocity.x = move_toward(velocity.x, move_speed * _direction * speed_mult, acceleration)
	else:
		var stop_fric = _current_friction if _current_friction > 0 else 0.5
		velocity.x = move_toward(velocity.x, 0, stop_fric)

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
		if _direction != 0: animation.play("Move")
		else: animation.play("Idle")
	else:
		if velocity.y > 0: animation.play("Fall")
		elif velocity.y < 0: animation.play("Jump")
	_facing_direction()

func _facing_direction() -> void:
	if facing_direction > 0:
		animation.flip_h = false
		bullet_spawn.position.x = abs(bullet_spawn.position.x)
	else:
		animation.flip_h = true
		bullet_spawn.position.x = -abs(bullet_spawn.position.x)

func shoot():
	for i in range(3):
		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.direction = facing_direction 
		var spawn_pos = bullet_spawn.global_position
		spawn_pos.x += facing_direction * i * 30
		bullet.global_position = spawn_pos

# --- FUNGSI COMBO ---
func add_combo() -> void:
	combo_count += 1
	_combo_timer = combo_time_limit # Reset timer balik ke 2 detik
	update_combo_ui()

func reset_combo() -> void:
	combo_count = 0
	update_combo_ui()

func update_combo_ui() -> void:
	if combo_label != null:
		if combo_count > 0:
			combo_label.text = str(combo_count) + " HIT!"
			
			# Tambahkan efek membal (wobble/scale) pakai Tween
			var tween = create_tween()
			# Atur titik pusat rotasi/scale label ke tengah
			combo_label.pivot_offset = combo_label.size / 2 
			combo_label.scale = Vector2(1.5, 1.5)
			tween.tween_property(combo_label, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BOUNCE)
		else:
			combo_label.text = "" # Hilangkan teks kalau combo putus

# --- FUNGSI UPDATE UI LAINNYA ---
func add_gem(amount):
	gems += amount
	update_gem_ui()

func update_gem_ui():
	if gem_label != null: gem_label.text = "Gems: " + str(gems)

func update_health_ui():
	if health_bar != null: health_bar.value = health

func take_damage(amount: float):
	if invincible: return
	invincible = true
	health -= amount
	update_health_ui()
	
	reset_combo() # Combo langsung putus kalau kena damage!
	
	if animation:
		animation.modulate = Color.RED 

	if health <= 0: 
		die()
		return

	await get_tree().create_timer(0.2).timeout
	
	if is_instance_valid(animation):
		animation.modulate = Color.WHITE
		
	invincible = false

func die():
	get_tree().reload_current_scene()
