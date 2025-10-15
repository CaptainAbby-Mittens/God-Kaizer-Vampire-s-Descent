# DamageBlock.gd
extends Area2D

@export var damage_amount: int = 12
@export var knockback_force: float = 300.0
@export var damage_cooldown: float = 0.5

var can_damage: bool = true

func _ready():
	body_entered.connect(_on_body_entered)
	collision_layer = 1
	collision_mask = 1

func _on_body_entered(body):
	if body.is_in_group("player") and can_damage:
		apply_damage_and_knockback(body)

func apply_damage_and_knockback(player):
	if is_instance_valid(player) and player.has_method("take_damage"):
		# Apply damage
		player.take_damage(damage_amount)
		
		# Calculate knockback direction (away from damage block)
		var knockback_direction = (player.global_position - global_position).normalized()
		
		# Apply knockback
		apply_knockback_to_player(player, knockback_direction)
		
		print("Applied ", damage_amount, " damage and knockback to player")
		
		# Start cooldown
		can_damage = false
		await get_tree().create_timer(damage_cooldown).timeout
		can_damage = true

func apply_knockback_to_player(player, direction: Vector2):
	# Try different knockback methods in order of preference
	if player.has_method("apply_knockback"):
		player.apply_knockback(direction * knockback_force)
	elif player is CharacterBody2D:
		player.velocity = direction * knockback_force
	elif player.has_method("add_force"):
		player.add_force(direction * knockback_force)
	else:
		# Fallback: directly modify position slightly
		player.global_position += direction * 20  # Small position nudge
