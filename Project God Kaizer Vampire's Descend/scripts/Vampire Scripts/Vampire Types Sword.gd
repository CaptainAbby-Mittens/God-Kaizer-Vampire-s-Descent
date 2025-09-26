# VampireEnemy.gd
extends "res://scripts/Vampire Scripts/Vampire sword.gd"

@export var vampire_type: String = "basic"

func _ready():

	super._ready()
	
	# Adjust stats based on vampire type
	match vampire_type:
		"basic":
			max_health = 60
			damage = 25
			move_speed = 90.0
			attack_range = 70.0
		"knight":
			max_health = 100
			damage = 35
			move_speed = 70.0
			attack_range = 80.0
		"boss":
			max_health = 200
			damage = 50
			move_speed = 60.0
			attack_range = 100.0
	
	current_health = max_health

# Override attack for vampire-specific behavior
func attack():
	if not can_attack:
		return
	
	can_attack = false
	print(vampire_type.capitalize(), " vampire attacking!")
	
	# Apply damage
	if player and global_position.distance_to(player.global_position) <= attack_range * 1.2:
		if player.has_method("take_damage"):
			player.take_damage(damage)
	
	# Vampire-specific cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	
	# Return to appropriate state
	if player and is_instance_valid(player) and global_position.distance_to(player.global_position) <= detection_range:
		current_state = State.CHASING
	else:
		current_state = State.IDLE
	
	update_sprite_frame()
	can_attack = true
