class_name Enemy
extends CharacterBody2D

@export var max_health: int = 30
var health: int

@onready var area = $Area2D
@onready var health_bar = $HealthBar

# 🔥 Panggil Node Animasi 🔥
@onready var anim = $AnimatedSprite2D

@export var damage: int = 1
@export var attack_delay: float = 1.0
var can_attack = true

@export var speed: float = 100.0
var direction: int = 1

var timer: float = 0.0
@export var patrol_time: float = 2.0 

func _ready():
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	
	# Mainkan animasi jalan (Pastikan nama animasinya sesuai!)
	anim.play("run")


func _process(_delta):
	var bodies = area.get_overlapping_bodies()

	for body in bodies:
		if body is Player2D and can_attack:
			body.take_damage(damage)
			attack_cooldown()


func _physics_process(delta):
	
	# 1. Menghitung waktu
	timer += delta
	
	# 2. Kalau sudah mencapai 2 detik, putar balik!
	if timer >= patrol_time:
		direction *= -1     # Balik arah
		timer = 0.0         # Reset timer

	# 🔥 3. Membalikkan gambar/sprite sesuai arah gerak 🔥
	if direction == 1:
		anim.flip_h = true  # Hadap kanan
	elif direction == -1:
		anim.flip_h = false   # Hadap kiri

	# 4. Gerakkan musuh
	velocity.x = direction * speed
	velocity.y = 0 
	
	move_and_slide()


func take_damage(amount):
	print("KENA DAMAGE!")
	health -= amount
	health_bar.value = health

	modulate = Color(1,0,0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1,1,1)

	if health <= 0:
		die()


func die():
	print("Enemy mati")
	queue_free()


func attack_cooldown():
	can_attack = false
	await get_tree().create_timer(attack_delay).timeout
	can_attack = true
