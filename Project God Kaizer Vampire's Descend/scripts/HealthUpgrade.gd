# HealthPickup.gd
extends Area2D

@export var health_increase: int = 25
@export var respawn_time: float = 10.0

# Color properties for the ColorRect
@export var active_color: Color = Color(0, 1, 0, 0.8)    # Green when active
@export var inactive_color: Color = Color(0, 0.3, 0, 0.3) # Dark green when inactive

@onready var color_rect = $ColorRect
@onready var collision = $CollisionShape2D

var is_active: bool = true

func _ready():
	# Connect signals
	body_entered.connect(_on_body_entered)
	
	# Set up collision
	collision_layer = 2  # Pickups layer
	collision_mask = 1   # Detect player layer
	
	# Set up ColorRect appearance


func _on_body_entered(body):
	if not is_active:
		return
	
	if body.is_in_group("player") and body.has_method("increase_max_health"):
		# Grant health to player
		body.increase_max_health(health_increase)
		print("Player gained +", health_increase, " max health!")
		color_rect.visible = false
		# Disable pickup temporarily
		collect_pickup()

func collect_pickup():
	is_active = false
	
	# Disable collision
	collision.set_deferred("disabled", true)
	
	# Update visual appearance

	
	# Optional: Play collection sound
	# $CollectionSound.play()
	
	# Start respawn timer
	start_respawn_timer()

func start_respawn_timer():
	await get_tree().create_timer(respawn_time).timeout
	respawn_pickup()

func respawn_pickup():
	is_active = true
	color_rect.visible = true
	# Enable collision
	collision.set_deferred("disabled", false)
	
	# Update visual appearance

	
	print("Health pickup respawned")



# Optional: Add a simple hover effect
func _process(delta):
	if is_active and color_rect:
		# Subtle hovering effect
		var hover_offset = sin(Time.get_ticks_msec() * 0.003) * 3.0
		color_rect.position.y = hover_offset
