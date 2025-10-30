# GameManager.gd
extends Node

# Tracks the player's current room position in the grid (e.g., [0, 0])
var current_room_coords = Vector2i(0, 0)
signal player_died
var player_weapon_path: String = ""
var player_has_weapon: bool = false
var current_game_over_layer: CanvasLayer = null
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
	
	
	Vector2i(1, 1): "res://scenes/Area2/room_1.tscn",
	Vector2i(2, 1): "res://scenes/Area2/room_2.tscn",  
	Vector2i(3, 1): "res://scenes/Area2/room_3.tscn",  
	Vector2i(4, 1): "res://scenes/Area2/room_4.tscn",  
	Vector2i(5, 1): "res://scenes/Area2/room_5.tscn",  
	Vector2i(6, 1): "res://scenes/Area2/room_6.tscn",  
	Vector2i(7, 1): "res://scenes/Area2/room_7.tscn",  # Start room
	Vector2i(8, 1): "res://scenes/Area2/room_8.tscn",
	Vector2i(9, 1): "res://scenes/Area2/room_9.tscn",  
	Vector2i(10, 1):"res://scenes/Area2/room_10.tscn",  
	Vector2i(11, 1):"res://scenes/Area2/room_11.tscn",  
	Vector2i(12, 1):"res://scenes/Area2/room_12.tscn",  
	Vector2i(13, 1):"res://scenes/Area2/room_13.tscn",  
	Vector2i(14, 1):"res://scenes/Area2/room_14.tscn",  # Start room
	Vector2i(15, 1):"res://scenes/Area2/room_15.tscn",
	Vector2i(16, 1):"res://scenes/Area2/room_16.tscn",  
	Vector2i(17, 1):"res://scenes/Area2/room_17.tscn",  
	Vector2i(18, 1):"res://scenes/Area2/room_18.tscn",  
	Vector2i(19, 1):"res://scenes/Area2/room_19.tscn",  
	Vector2i(20, 1):"res://scenes/Area2/room_20.tscn", 
	
	Vector2i(1, 2): "res://scenes/Area3/room_1.tscn",
	Vector2i(2, 2): "res://scenes/Area3/room_2.tscn",  
	Vector2i(3, 2): "res://scenes/Area3/room_3.tscn",  
	Vector2i(4, 2): "res://scenes/Area3/room_4.tscn",  
	Vector2i(5, 2): "res://scenes/Area3/room_5.tscn",  
	Vector2i(6, 2): "res://scenes/Area3/room_6.tscn",  
	Vector2i(7, 2): "res://scenes/Area3/room_7.tscn",  # Start room
	Vector2i(8, 2): "res://scenes/Area3/room_8.tscn",
	Vector2i(9, 2): "res://scenes/Area3/room_9.tscn",  
	Vector2i(10,2):"res://scenes/Area3/room_10.tscn",  
	Vector2i(11, 2):"res://scenes/Area3/room_11.tscn",  
	Vector2i(12, 2):"res://scenes/Area3/room_12.tscn",  
	Vector2i(13, 2):"res://scenes/Area3/room_13.tscn",  
	Vector2i(14, 2):"res://scenes/Area3/room_14.tscn",  # Start room
	Vector2i(15, 2):"res://scenes/Area3/room_15.tscn",
	Vector2i(16, 2):"res://scenes/Area3/room_16.tscn",  
	Vector2i(17, 2):"res://scenes/Area3/room_17.tscn",  
	Vector2i(18, 2):"res://scenes/Area3/room_18.tscn",  
	Vector2i(19, 2):"res://scenes/Area3/room_19.tscn",  
	Vector2i(20, 2):"res://scenes/Area3/room_20.tscn",  
	
	Vector2i(1, 3): "res://scenes/Area4/room_1.tscn",
	Vector2i(2, 3): "res://scenes/Area4/room_2.tscn",  
	Vector2i(3, 3): "res://scenes/Area4/room_3.tscn",  
	Vector2i(4, 3): "res://scenes/Area4/room_4.tscn",  
	Vector2i(5, 3): "res://scenes/Area4/room_5.tscn",  
	Vector2i(6, 3): "res://scenes/Area4/room_6.tscn",  
	Vector2i(7, 3): "res://scenes/Area4/room_7.tscn",  # Start room
	Vector2i(8, 3): "res://scenes/Area4/room_8.tscn",
	Vector2i(9, 3): "res://scenes/Area4/room_9.tscn",  
	Vector2i(10, 3):"res://scenes/Area4/room_10.tscn",  
	Vector2i(11, 3):"res://scenes/Area4/room_11.tscn",  
	Vector2i(12, 3):"res://scenes/Area4/room_12.tscn",  
	Vector2i(13, 3):"res://scenes/Area4/room_13.tscn",  
	Vector2i(14, 3):"res://scenes/Area4/room_14.tscn",  # Start room
	Vector2i(15, 3):"res://scenes/Area4/room_15.tscn",
	Vector2i(16, 3):"res://scenes/Area4/room_16.tscn",  
	Vector2i(17, 3):"res://scenes/Area4/room_17.tscn",  
	Vector2i(18, 3):"res://scenes/Area4/room_18.tscn",  
	Vector2i(19, 3):"res://scenes/Area4/room_19.tscn",  
	Vector2i(20, 3):"res://scenes/Area4/room_20.tscn", 
	
	Vector2i(1, 4): "res://scenes/Area5/room_1.tscn",
	Vector2i(2, 4): "res://scenes/Area5/room_2.tscn",  
	Vector2i(3, 4): "res://scenes/Area5/room_3.tscn",  
	Vector2i(4, 4): "res://scenes/Area5/room_4.tscn",  
	Vector2i(5, 4): "res://scenes/Area5/room_5.tscn",  
	Vector2i(6, 4): "res://scenes/Area5/room_6.tscn",  
	Vector2i(7, 4): "res://scenes/Area5/room_7.tscn",  # Start room
	Vector2i(8, 4): "res://scenes/Area5/room_8.tscn",
	Vector2i(9, 4): "res://scenes/Area5/room_9.tscn",  
	Vector2i(10, 4):"res://scenes/Area5/room_10.tscn",  
	Vector2i(11, 4):"res://scenes/Area5/room_11.tscn",  
	Vector2i(12, 4):"res://scenes/Area5/room_12.tscn",  
	Vector2i(13, 4):"res://scenes/Area5/room_13.tscn",  
	Vector2i(14, 4):"res://scenes/Area5/room_14.tscn",  # Start room
	Vector2i(15, 4):"res://scenes/Area5/room_15.tscn",
	Vector2i(16, 4):"res://scenes/Area5/room_16.tscn",  
	Vector2i(17, 4):"res://scenes/Area5/room_17.tscn",  
	Vector2i(18, 4):"res://scenes/Area5/room_18.tscn",  
	Vector2i(19, 4):"res://scenes/Area5/room_19.tscn",  
	Vector2i(20, 4):"res://scenes/Area5/room_20.tscn", 
	
	Vector2i(1, 5):"res://scenes/AreaBoss/PreBossRoom.tscn",
	Vector2i(2, 5):"res://scenes/AreaBoss/xBoss.tscn",
	Vector2i(3, 5):"res://scenes/AreaBoss/yBoss.tscn",
	Vector2i(4, 5):"res://scenes/AreaBoss/zFinalBoss.tscn",
	Vector2i(5, 5):"res://scenes/AreaBoss/Congratulations.tscn",
	  
}
var player_damage = 30
var next_threshold_index = 0
var base_threshold = 400
var threshold_step = 250
# Playtime tracking
var playtime: float = 0.0
var is_timer_running: bool = false
var start_time: float = 0.0
var has_key1: bool = false
var has_key2: bool = false
var has_key3: bool = false
var has_key4: bool = false
var boss_killed_1: bool = false
var score: int = 0
var vampirism: bool = false
var firesword: bool = false
var shield: int = 0
var crit: float = 12
var bleed: int = 0
var autoheal: bool = false
var fireball: bool = false
var supermode: bool = false
# Signal for UI updates (optional)
signal playtime_updated(playtime_seconds)

func crit_strike():
	if randf()< crit/100:
		return RandomNumberGenerator.new().randf_range(1.25, 1.75)
	else:
		return 1
func grant_shield():
	if randf() < 0.15 and shield <=3:
		shield +=1

func check_score_thresholds():
	var next_threshold = base_threshold + next_threshold_index * threshold_step
	if score >= next_threshold:
		_increase_player_stats()
		next_threshold_index += 1
		
func _increase_player_stats():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
		
	# Example stat scaling logic
	player.max_health += 30
	player.current_health = player.max_health
	player.attack_damage += 4 if player.has_method("attack_damage") else 0
	
	crit += 1
	shield = 3

	print("🩸 Player leveled up! New stats → HP:", player.max_health, ", Crit:", crit, ", Shield:", shield)


func add_score(addScore):
	score += addScore
	check_score_thresholds()
func reset_score():
	score = 0

func respawn_all_potions():
	print("Respawning all potions...")
	get_tree().call_group("potions", "respawn_potion")

func reset_potions_on_restart():
	# Called when start button is pressed
	respawn_all_potions()
	
func restart_playtime_timer():
	# Reset all timer variables
	playtime = 0.0
	is_timer_running = false
	start_time = 0.0
	print("Playtime timer reset and ready to start")
	
func start_playtime_timer():
	if not is_timer_running:
		is_timer_running = true
		start_time = Time.get_ticks_msec() / 1000.0
		print("Playtime timer started")

func stop_playtime_timer():
	if is_timer_running:
		is_timer_running = false
		# Add the elapsed time to total playtime
		var elapsed = (Time.get_ticks_msec() / 1000.0) - start_time
		playtime += elapsed
		print("Playtime timer stopped. Total: ", playtime, " seconds")

func reset_playtime_timer():
	playtime = 0.0
	is_timer_running = false
	print("Playtime timer reset")

func get_current_playtime() -> float:
	if is_timer_running:
		var current_elapsed = (Time.get_ticks_msec() / 1000.0) - start_time
		return playtime + current_elapsed
	else:
		return playtime

func get_formatted_playtime() -> String:
	var total_seconds = get_current_playtime()
	var minutes = int(total_seconds) / 60
	var seconds = int(total_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]
	

var player_stats = {
	"max_health": 100,
	"current_health": 100,
	# Add other stats like weapons, abilities, etc.
}


# Optional: Add a formatted time method

func _process(delta):
	if is_timer_running:
		# Optional: emit signal for UI updates every second
		var current_time = Time.get_ticks_msec() / 1000.0
		if int(current_time) != int(current_time - delta):
			playtime_updated.emit(get_current_playtime())
func cleanup_vampires():
	var vampires = get_tree().get_nodes_in_group("enemy")
	print("Cleaning up ", vampires.size(), " vampires")
	for vampire in vampires:
		if is_instance_valid(vampire):
			vampire.queue_free()
func _ready():

	
	print("GameManager loaded! World map has ", world_map.size(), " rooms.")
	print("Available rooms: ", world_map)
func cleanup_current_room():
	if current_game_over_layer and is_instance_valid(current_game_over_layer):
		current_game_over_layer.queue_free()
		current_game_over_layer = null
	# Force cleanup of all temporary objects
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("weapon", "queue_free")
	get_tree().call_group("projectile", "queue_free")
# This function will be called to change rooms
func change_room(direction: Vector2i):

	save_player_stats()
	
	# Use call_deferred for cleanup to avoid physics callback issues
	call_deferred("_deferred_change_room", direction)

func _deferred_change_room(direction: Vector2i):
	
	var next_scene_vector = current_room_coords + direction
	if world_map.has(next_scene_vector):
		var scene_path = world_map[next_scene_vector]
		var scene_resource = load(scene_path)  # This gets the String path
		print("Loading scene: ", scene_path)
		get_tree().change_scene_to_packed(scene_resource)

	
	cleanup_current_room()
	var new_room_coords = current_room_coords + direction
	print("Changing to room at coordinates: ", new_room_coords)
	
	# Use call_deferred for vampire cleanup
	call_deferred("cleanup_vampires")
	
	if world_map.has(new_room_coords):
		current_room_coords = new_room_coords
		get_tree().change_scene_to_file(world_map[new_room_coords])
		
		# WAIT for the new scene to load
		await get_tree().process_frame
		
		# Reposition the player based on travel direction
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var screen_width = 640
			if direction == Vector2i.RIGHT:	# Entering from left
				player.global_position.x = 50  # Place near left edge
			elif direction == Vector2i.LEFT:   # Entering from right
				player.global_position.x = screen_width - 50  # Place near right edge
		
		await get_tree().create_timer(0.1).timeout
		restore_player_stats()
func teleport_to_room(target_coords: Vector2i, spawn_direction: Vector2i = Vector2i.RIGHT):
	save_player_stats()
	call_deferred("_deferred_teleport_to_room", target_coords, spawn_direction)

func _deferred_teleport_to_room(target_coords: Vector2i, spawn_direction: Vector2i):
	cleanup_current_room()
	print("Teleporting to room at coordinates: ", target_coords)
	current_room_coords = target_coords 
	call_deferred("cleanup_vampires")
	
	if world_map.has(target_coords):
		current_room_coords = target_coords
		get_tree().change_scene_to_file(world_map[target_coords])
		
		# WAIT for the new scene to load
		await get_tree().process_frame
		
		# Reposition the player based on spawn direction
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var screen_width = 640
			if spawn_direction == Vector2i.RIGHT:    # Spawn from left
				player.global_position.x = 50
			elif spawn_direction == Vector2i.LEFT:   # Spawn from right
				player.global_position.x = screen_width - 50
			elif spawn_direction == Vector2i.DOWN:   # Spawn from top
				player.global_position.y = 50
			elif spawn_direction == Vector2i.UP:     # Spawn from bottom
				player.global_position.y = 360 - 50
		
		await get_tree().create_timer(0.1).timeout
		restore_player_stats()
	else:
		print("ERROR: Room coordinates not found in world_map: ", target_coords)
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
