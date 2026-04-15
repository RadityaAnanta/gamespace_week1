class_name Enemy
extends CharacterBody2D

@export var max_health: int = 30
var health: int

@onready var area = $Area2D
@onready var health_bar = $HealthBar

@export var damage: int = 1
@export var attack_delay: float = 1.0

var can_attack = true

func _ready():
	health = max_health

	# setup health bard
	health_bar.max_value = max_health
	health_bar.value = health


func _process(_delta):

	var bodies = area.get_overlapping_bodies()

	for body in bodies:
		if body is Player2D and can_attack:
			body.take_damage(damage)
			attack_cooldown()


func take_damage(amount):

	print("KENA DAMAGE!")

	health -= amount
	print("Enemy HP:", health)

	health_bar.value = health

	# efek kena
	modulate = Color(1,0,0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1,1,1)

	if health <= 0:
		die()


func die():
	print("Enemy mati")
	queue_free()   # 🔥 WAJIB


func attack_cooldown():
	can_attack = false
	await get_tree().create_timer(attack_delay).timeout
	can_attack = true
