# GameManager.gd
extends Node

# Tracks the player's current room position in the grid (e.g., [0, 0])
var current_room_coords = Vector2i(0, 0)
signal player_died
# A dictionary to act as our "world map". Key: Vector2i Coordinates, Value: Room scene file path
var world_map = {
	Vector2i(0, 0): "res://scenes/Area1/room_start.tscn",  # Start room
	Vector2i(1, 0): "res://scenes/Area1/room_1.tscn",
	Vector2i(2, 0): "res://scenes/Area1/room_2.tscn",  
	Vector2i(3, 0): "res://scenes/Area1/room_3.tscn",  
	Vector2i(4, 0): "res://scenes/Area1/room_4.tscn",  
	Vector2i(5, 0): "res://scenes/Area1/room_5.tscn",  
	Vector2i(6, 0): "res://scenes/Area1/room_6.tscn",  
	Vector2i(7, 0): "res://scenes/Area1/room_7.tscn",  # Start room
	Vector2i(8, 0): "res://scenes/Area1/room_8.tscn",
	Vector2i(9, 0): "res://scenes/Area1/room_9.tscn",  
	Vector2i(10, 0):"res://scenes/Area1/room_10.tscn",  
	Vector2i(11, 0):"res://scenes/Area1/room_11.tscn",  
	Vector2i(12, 0):"res://scenes/Area1/room_12.tscn",  
	Vector2i(13, 0):"res://scenes/Area1/room_13.tscn",  
	Vector2i(14, 0):"res://scenes/Area1/room_14.tscn",  # Start room
	Vector2i(15, 0):"res://scenes/Area1/room_15.tscn",
	Vector2i(16, 0):"res://scenes/Area1/room_16.tscn",  
	Vector2i(17, 0):"res://scenes/Area1/room_17.tscn",  
	Vector2i(18, 0):"res://scenes/Area1/room_18.tscn",  
	Vector2i(19, 0):"res://scenes/Area1/room_19.tscn",  
	Vector2i(20, 0):"res://scenes/Area1/room_20.tscn",  
}

var player_stats = {
	"max_health": 100,
	"current_health": 100,
	# Add other stats like weapons, abilities, etc.
}

func _ready():
	print("GameManager loaded! World map has ", world_map.size(), " rooms.")
	print("Available rooms: ", world_map)

# This function will be called to change rooms
func change_room(direction: Vector2i):
	save_player_stats()

	var new_room_coords = current_room_coords + direction
	print("Changing to room at coordinates: ", new_room_coords)
	
	if world_map.has(new_room_coords):
		current_room_coords = new_room_coords
		get_tree().change_scene_to_file(world_map[new_room_coords])
		
		# WAIT for the new scene to load
		await get_tree().process_frame
		
		# Reposition the player based on travel direction
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var screen_width = 640
			if direction == Vector2i.RIGHT:    # Entering from left
				player.global_position.x = 50  # Place near left edge
			elif direction == Vector2i.LEFT:   # Entering from right
				player.global_position.x = screen_width - 50  # Place near right edge
	await get_tree().create_timer(0.1).timeout
	restore_player_stats()


func save_player_stats():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player_stats["max_health"] = player.max_health
		player_stats["current_health"] = player.current_health
		if player.current_health <= 0:
			player_died.emit()  # ← Emit the death signal
			print("GameManager: Player death detected - emitting signal")

func restore_player_stats():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.max_health = player_stats["max_health"]
		player.current_health = player_stats["current_health"]
		player.health_updated.emit(player.current_health, player.max_health)
func reposition_player_in_new_room(direction: Vector2i):
	# Find the player in the newly loaded scene
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var screen_width = 640
		var screen_height = 360
		
		if direction == Vector2i.RIGHT:    # Came from left
			player.global_position.x = 50  # Place near left edge
			player.global_position.y = screen_height / 2  # Center vertically
			
		elif direction == Vector2i.LEFT:   # Came from right  
			player.global_position.x = screen_width - 50  # Place near right edge
			player.global_position.y = screen_height / 2  # Center vertically
			
		elif direction == Vector2i.DOWN:   # Came from above
			player.global_position.y = 50  # Place near top
			player.global_position.x = screen_width / 2  # Center horizontally
			
		elif direction == Vector2i.UP:     # Came from below
			player.global_position.y = screen_height - 50  # Place near bottom
			player.global_position.x = screen_width / 2  # Center horizontally
			
		print("Player repositioned to: ", player.global_position)
