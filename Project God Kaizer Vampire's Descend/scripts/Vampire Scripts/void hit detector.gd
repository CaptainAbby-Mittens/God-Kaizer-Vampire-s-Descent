extends Area2D

@export var damage_amount: int = 25
@export var knockback_force: float = 400.0
@export var cooldown_time: float = 2.0  # Increased cooldown
@export var respawn_on_restart: bool = true

# Use CollisionPolygon2D like your potion
@onready var visual_node = _find_visual_node()
@onready var collision = $Collider

var is_active: bool = true

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("vampire_damage")
	
	if collision:
		collision_layer = 2
		collision_mask = 1
	else:
		push_error("CollisionPolygon2D not found in vampire damage area: " + name)
	
	print("Vampire damage area ready | Cooldown: ", cooldown_time, "s | Knockback: ", knockback_force)

func _find_visual_node():
	# Look for any visual node
	for child in get_children():
		if child is Sprite2D or child is AnimatedSprite2D or child is ColorRect:
			return child
	print("No visual node found for vampire damage area: ", name)
	return null

func _on_body_entered(body):
	if not is_active:
		return
	
	if body.is_in_group("player"):
		apply_effect(body)
		start_cooldown()

func apply_effect(player):
	# Apply damage (same as before)
	if player.has_method("take_damage"):
		player.take_damage(damage_amount)
		print("Player took ", damage_amount, " damage from vampire touch!")
	else:
		print("Player doesn't have take_damage method!")
	
	# Apply knockback
	apply_knockback(player)

func apply_knockback(player):
	if player.has_method("apply_knockback"):
		# Calculate knockback direction away from vampire
		var knockback_direction = (player.global_position - global_position).normalized()
		player.apply_knockback(knockback_direction * knockback_force)
		print("Applied knockback to player: ", knockback_direction * knockback_force)
	
	elif player.has_method("add_force") or player.has_method("add_impulse"):
		# Alternative knockback methods
		var knockback_direction = (player.global_position - global_position).normalized()
		var knockback_vector = knockback_direction * knockback_force
		
		if player.has_method("add_force"):
			player.add_force(knockback_vector)
		elif player.has_method("add_impulse"):
			player.add_impulse(knockback_vector)
		print("Applied knockback via force/impulse: ", knockback_vector)
	
	elif player is CharacterBody2D:
		# Direct velocity manipulation for CharacterBody2D
		var knockback_direction = (player.global_position - global_position).normalized()
		player.velocity += knockback_direction * knockback_force
		print("Applied knockback via velocity: ", knockback_direction * knockback_force)
	
	else:
		print("Player doesn't have knockback method - available methods: ", _get_knockback_methods(player))

func _get_knockback_methods(player: Node) -> Array:
	var methods = []
	var method_list = player.get_method_list()
	for method in method_list:
		var method_name = method["name"].to_lower()
		if "knockback" in method_name or "force" in method_name or "impulse" in method_name or "push" in method_name:
			methods.append(method["name"])
	return methods

func start_cooldown():
	is_active = false
	# Optional: Visual feedback during cooldown
	if visual_node:
		visual_node.modulate = Color(0.5, 0.5, 0.5, 0.5)  # Dim during cooldown
	
	# Wait for cooldown
	await get_tree().create_timer(cooldown_time).timeout
	
	# Re-enable
	is_active = true
	if visual_node:
		visual_node.modulate = Color(1, 1, 1, 1)  # Restore normal color
	print("Vampire damage area ready again")

# Keep the respawn methods if needed
func respawn_damage_area():
	is_active = true
	if visual_node:
		visual_node.visible = true
		visual_node.modulate = Color(1, 1, 1, 1)
	if collision:
		collision.set_deferred("disabled", false)
	print("Vampire damage area respawned")

func disable_damage_area():
	is_active = false
	if visual_node:
		visual_node.visible = false
	if collision:
		collision.set_deferred("disabled", true)
	print("Vampire damage area disabled")
