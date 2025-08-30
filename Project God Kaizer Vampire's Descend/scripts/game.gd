# game.gd
extends Node2D

# Persistent nodes
var player = null
var current_room = null
var health_display = null

func _ready():
	print("Game starting...")
	
	# Create persistent player (only once!)
	create_player()
	
	# Create health display (only once!)
	create_health_display()
	
	# Load the first room
	load_room(load("res://scenes/Room_Start.tscn"))

func create_player():
	# Create the player once and keep it persistent
	player = load("res://Player.tscn").instantiate()
	add_child(player)
	print("Persistent player created!")

func create_health_display():
	# Create health display once
	health_display = load("res://UI_HealthValue.tscn").instantiate()
	add_child(health_display)
	
	# Connect to player health updates
	if player:
		player.health_updated.connect(health_display.update_health)
		health_display.update_health(player.current_health, player.max_health)
		print("Health display connected to player!")

func load_room(room_scene: PackedScene):
	print("Loading room: ", room_scene.resource_path)
	
	# Remove current room if it exists
	if current_room:
		current_room.queue_free()
		await get_tree().process_frame  # Wait for cleanup
	
	# Load new room
	current_room = room_scene.instantiate()
	add_child(current_room)
	
	# Position player at the appropriate entrance
	position_player_in_room()

func position_player_in_room():
	# Position based on which direction we came from
	# You can add Position2D nodes named "EntryLeft", "EntryRight" in your rooms
	var entry_point = null
	
	# Example: if coming from right, use left entry point
	# You'll need to track the direction in your room change logic
	if GameManager.last_direction == Vector2i.RIGHT:
		entry_point = current_room.get_node_or_null("EntryLeft")
	elif GameManager.last_direction == Vector2i.LEFT:
		entry_point = current_room.get_node_or_null("EntryRight")
	
	# Use entry point or default position
	if entry_point:
		player.global_position = entry_point.global_position
	else:
		player.global_position = Vector2(320, 250)  # Center of room

# Optional: Room transition function called by player
func change_room(direction: Vector2i, next_room_path: String):
	GameManager.last_direction = direction  # Store direction for positioning
	load_room(load(next_room_path))
