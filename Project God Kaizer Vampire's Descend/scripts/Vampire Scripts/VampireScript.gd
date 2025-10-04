# VampireEnemy.gd


extends "res://scripts/Vampire Scripts/Vampire sword.gd"

@export var vampire_type: String = "basic"

func _ready():

	super._ready()
	
	# Adjust stats based on vampire type
	match vampire_type:
		"red":
			max_health = 40
			damage = 20
			move_speed = 60
			attack_range = 50
		"blue":
			max_health = 100
			damage = 35
			move_speed = 110
			attack_range = 50
			
		"black":
			max_health = 200
			damage = 70
			move_speed = 50
			attack_range = 80.0
	
	current_health = max_health

# Override attack for vampire-specific behavior
