# HealthUpgrade.gd
extends Area2D

@export var health_increase: int = 25

var color_rect: ColorRect
var collision: CollisionShape2D
var is_active: bool = true

# Animation variables
var float_time: float = 0.0
var float_height: float = 10.0  # How high it floats
var float_speed: float = 2.0    # How fast it floats

func _ready():
	# Find nodes safely
	color_rect = get_node_or_null("ColorRect")
	collision = get_node_or_null("CollisionShape2D")
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	
	# Set up collision if found
	if collision:
		collision_layer = 2  # Pickups layer
		collision_mask = 1   # Detect player layer
	else:
		push_error("CollisionShape2D not found!")
	
	# Add to group for respawning when player dies
	add_to_group("health_upgrades")
	
	# Set initial visibility
	update_visual_appearance()

func _process(delta):
	if is_active and color_rect:
		# Floating animation - only when active
		float_time += delta
		var float_offset = sin(float_time * float_speed) * float_height
		color_rect.position.y = float_offset

func _on_body_entered(body):
	if not is_active:
		return
	
	if body.is_in_group("player") and body.has_method("increase_max_health"):
		# Grant health to player
		body.increase_max_health(health_increase)
		print("Player gained +", health_increase, " max health!")
		
		# Hide and disable pickup - will only reappear when player dies
		collect_pickup()

func collect_pickup():
	is_active = false
	
	# Disable collision
	if collision:
		collision.set_deferred("disabled", true)
	
	# Hide the visual
	update_visual_appearance()
	
	print("Health upgrade collected. Waiting for player death to respawn.")

func respawn_on_player_death():
	is_active = true
	
	# Enable collision
	if collision:
		collision.set_deferred("disabled", false)
	
	# Reset animation position
	if color_rect:
		color_rect.position.y = 0
	
	# Show the visual again
	update_visual_appearance()
	
	print("Health upgrade respawned after player death")

func update_visual_appearance():
	if color_rect:
		color_rect.visible = is_active
		if is_active:
			color_rect.color = Color(0, 1, 0, 0.8)  # Bright green when active
			# Reset position for clean animation start
			color_rect.position.y = 0
		# When not active, it's just hidden completely
