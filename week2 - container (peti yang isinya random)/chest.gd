extends Node2D

@onready var anim = $AnimatedSprite2D
@onready var area = $Area2D

var opened = false


var blue_gem = preload("res://week2 - container (peti yang isinya random)/blue_gem.tscn")
var red_gem = preload("res://week2 - container (peti yang isinya random)/red_gem.tscn")
var yellow_gem = preload("res://week2 - container (peti yang isinya random)/yellow_gem.tscn")
var green_gem = preload("res://week2 - container (peti yang isinya random)/green_gem.tscn")

var gems = []

func _ready():



	randomize()

	gems = [
		blue_gem,
		red_gem,
		yellow_gem,
		green_gem
	]


func _process(_delta):

	# cek tombol interact
	if Input.is_action_just_pressed("interact"):
		check_player()


func check_player():

	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body is Player2D:
			open_chest()


func open_chest():

	if opened:
		return

	opened = true
	anim.play("open")
	spawn_random_gem()


func spawn_random_gem():

	var gem_scene = gems.pick_random()
	var gem = gem_scene.instantiate()
	get_parent().add_child(gem)
	gem.global_position = global_position + Vector2(0,-40)
