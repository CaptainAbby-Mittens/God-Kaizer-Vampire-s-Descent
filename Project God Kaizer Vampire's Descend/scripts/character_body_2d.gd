extends CharacterBody2D

# === CASTLEVANIA-STYLE MOVEMENT PARAMETERS ===
@export var max_walk_speed = 160.0        # Soma walks fairly slow
@export var walk_acceleration = 4000.0     # Crisp but not instant acceleration
@export var ground_friction = 1000.0       # Slight slide when stopping
var current_weapon = null
var current_weapon_path: String = ""
var facing_right: bool = true  # Track facing direction
@export var max_air_speed = 160.0         # Slightly faster in air
@export var air_acceleration = 700.0      # Less control in air
@export var air_friction = 200.0          # Less friction in air

@export var jump_velocity = -320.0        # Medium-high jump
@export var short_jump_velocity = -320.0  # Short hop for tap jumps
@export var gravity = 900.0               # Snappy fall speed
@export var max_fall_speed = 400.0        # Terminal velocity
# Health variables
@export var max_health = 100
var current_health : int = max_health

# Health bar nodes
@onready var health_bar = $HealthBar  # We'll create this node next
@onready var character_sprite = $Sprite2D 
@onready var weapon_sprite = $WeaponSprite  # Make sure this node exists

var can_attack: bool = true
var attack_cooldown: float = 0.0
# Coyote time and jump buffering
var coyote_time = 0.08    # Time after leaving ledge to still jump
var coyote_timer = 0.0
var jump_buffer_time = 0.1  # Time before landing to buffer jump
var jump_buffer_timer = 0.0

var is_jump_button_held = false
var jump_start_time = 0.0
var max_jump_hold_time = 0.2  # Maximum time to hold jump for full height

# Safety flag
var physics_ready = false
var has_key: bool = false

func pick_up_key():
	has_key = true
	print("Player picked up a key!")

func use_key() -> bool:
	if has_key:
		has_key = false
		print("Player used a key!")
		return true
	return false

func _ready():	

	# Make sure player is in the correct group
	add_to_group("player")
	print("Player: Added to 'player' group")

	# Load weapon from GameManager if player had one
	if GameManager.player_has_weapon and GameManager.player_weapon_path != "":
		print("Player: Loading weapon from GameManager")
		current_weapon_path = GameManager.player_weapon_path
		equip_weapon_from_path()

	# Wait until physics is properly set up
	await get_tree().physics_frame
	physics_ready = true
	current_health = max_health
	health_updated.emit(current_health, max_health)

	add_to_group("player")
func _process(delta):
	if current_weapon and current_weapon.has_method("update_collision_position"):
		current_weapon.update_collision_position()
	queue_redraw()
	update_weapon_position()
	if Input.is_action_just_pressed("attack"):
		print("X key pressed")
		attack()


func equip_weapon(weapon_node):
	print("Player: Equipping weapon")
	
	
	# Store the weapon scene path in GameManager for persistence
	GameManager.player_weapon_path = weapon_node.get_scene_file_path()
	GameManager.player_has_weapon = true
	
	print("Weapon path stored: ", GameManager.player_weapon_path)
	
	# Remove old weapon if exists
	if current_weapon:
		current_weapon.queue_free()
		current_weapon = null
	
	# Create new instance and make it a child of the player
	if GameManager.player_weapon_path != "":
		call_deferred("_deferred_equip_weapon")
	
	# Remove the world pickup weapon
	weapon_node.queue_free()
	

		
func _deferred_equip_weapon():
	if GameManager.player_weapon_path != "":
		var weapon_scene = load(GameManager.player_weapon_path).instantiate()
		current_weapon = weapon_scene
		
		# Add as child of player
		add_child(weapon_scene)
		weapon_scene.position = Vector2(50, 0)
		weapon_scene.set_as_top_level(false)
		weapon_scene.visible = false
		
		if weapon_scene.has_method("equip_to_player"):
			weapon_scene.equip_to_player(self)
		
		print("Weapon equipped as child of player")

func update_weapon_position():
	if current_weapon:
		if facing_right:
			# Sword on right side (facing right)
			current_weapon.position = Vector2(28, 13)
			# Keep sword facing normal direction
			current_weapon.scale.x = 1
		else:
			# Sword on left side (facing left)  
			current_weapon.position = Vector2(5, 13)
			# Flip sword to face left
			current_weapon.scale.x = -1
		
		# Force collision to update immediately when flipping
		if current_weapon.has_method("update_collision_position"):
			current_weapon.update_collision_position()


func equip_weapon_from_path():
	if current_weapon_path != "":
		var weapon_scene = load(current_weapon_path).instantiate()
		current_weapon = weapon_scene
		add_child(weapon_scene)
		current_weapon.set_as_top_level(false)
		
		# Set initial position based on facing
		update_weapon_position()
		
		# Start with weapon HIDDEN
		current_weapon.visible = false
		
		# Call equip method using call_deferred
		if weapon_scene.has_method("equip_to_player"):
			weapon_scene.call_deferred("equip_to_player", self)
		
		print("Weapon equipped with directional positioning")



func attack():
	if current_weapon:
		print("Attacking with weapon")
		
		# Make weapon visible before playing animation
		current_weapon.visible = true
		
		# Get AnimationPlayer and play swing animation
		var animation_player = current_weapon.get_node("AnimationPlayer")
		if animation_player:
			# Signal weapon to start damaging
			if current_weapon.has_method("start_attack"):
				current_weapon.start_attack()
			
			# Connect to animation_finished signal
			if not animation_player.is_connected("animation_finished", _on_weapon_animation_finished):
				animation_player.connect("animation_finished", _on_weapon_animation_finished)
			
			animation_player.play("Swing")
			print("Playing Swing animation")
	else:
		print("No weapon equipped")

func _on_weapon_animation_finished(anim_name):
	if anim_name == "Swing" and current_weapon:
		# Signal weapon to stop damaging
		if current_weapon.has_method("end_attack"):
			current_weapon.end_attack()
		
		# Hide the weapon after swing animation finishes
		current_weapon.visible = false
		print("Weapon hidden after swing animation")




func handle_weapon_input():
	if Input.is_action_just_pressed("attack") and can_attack and current_weapon:
		attack_with_weapon()

func attack_with_weapon():
	if attack_cooldown > 0 or not current_weapon:
		return
	
	can_attack = false
	current_weapon.attack()
	
	attack_cooldown = 1.0 / current_weapon.attack_speed
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

# Add this function to handle weapon pickup




func update_weapon_sprite(weapon):
	if weapon_sprite and weapon.has_node("Sprite2D"):
		var weapon_sprite_node = weapon.get_node("Sprite2D")
		weapon_sprite.texture = weapon_sprite_node.texture
		
		# Copy sprite properties if they exist
		if weapon_sprite_node is Sprite2D:
			weapon_sprite.hframes = weapon_sprite_node.hframes
			weapon_sprite.vframes = weapon_sprite_node.vframes
			weapon_sprite.frame = weapon_sprite_node.frame
		
		weapon_sprite.visible = true
		print("Weapon sprite updated")
	else:
		print("Warning: Could not update weapon sprite")


func _deferred_drop_weapon():
	if current_weapon:
		# Remove from player
		remove_child(current_weapon)
		
		# Add back to the scene
		get_parent().add_child(current_weapon)
		
		# Position it where the player is
		current_weapon.global_position = global_position
		current_weapon.is_equipped = false
		
		# Reset the weapon's properties with set_deferred
		if current_weapon.has_node("Sprite2D"):
			current_weapon.get_node("Sprite2D").visible = true
		if current_weapon.has_node("CollisionShape2D"):
			current_weapon.get_node("CollisionShape2D").set_deferred("disabled", false)
		
		current_weapon = null
		
		# Hide player's weapon sprite
		weapon_sprite.visible = false
		print("Weapon dropped")
func _physics_process(delta):
	var input_direction = Input.get_axis("ui_left", "ui_right")
	if input_direction != 0:
		facing_right = input_direction > 0
		#update_weapon_position()
	# Safety check - don't process physics until ready
	if not physics_ready or not is_inside_tree():
		return
	
	handle_timers(delta)
	handle_gravity(delta)
	handle_movement(delta)
	handle_jump_input()
	handle_jumping(delta)
	handle_room_transition()
	
	# Safe move_and_slide
	if is_inside_tree() and get_world_2d():
		move_and_slide()
	

func handle_timers(delta):
	# Safe physics check
	if not can_use_physics():
		return
	
	# Coyote time (jump after leaving platform)
	if is_on_floor():
		coyote_timer = coyote_time
	elif coyote_timer > 0:
		coyote_timer -= delta
	
	# Jump buffer (input before landing)
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

func handle_gravity(delta):
	# Apply gravity with terminal velocity
	if can_use_physics() and not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)

func handle_movement(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Apply movement with different ground/air physics
	if can_use_physics() and is_on_floor():
		handle_ground_movement(direction, delta)
	elif can_use_physics():
		handle_air_movement(direction, delta)
		
	handle_sprite_flip(direction)

func handle_ground_movement(direction, delta):
	if direction != 0:
		# Accelerate to walk speed
		velocity.x = move_toward(velocity.x, direction * max_walk_speed, walk_acceleration * delta)
	else:
		# Apply friction - slight slide
		velocity.x = move_toward(velocity.x, 0, ground_friction * delta)

func handle_air_movement(direction, delta):
	if direction != 0:
		# Air control - can change direction but slower acceleration
		velocity.x = move_toward(velocity.x, direction * max_air_speed, air_acceleration * delta)
	else:
		# Less friction in air
		velocity.x = move_toward(velocity.x, 0, air_friction * delta)
func handle_sprite_flip(direction):
	# Only flip if we're actually moving in a direction
	if direction != 0:
		# Flip the sprite to face the movement direction
		if direction > 0:
			character_sprite.scale.x = 1  # Face right (normal scale)
		elif direction < 0:
			character_sprite.scale.x = -1 # Face left (flipped horizontally)
func handle_jump_input():
	# Detect when jump button is first pressed
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
		is_jump_button_held = true
		jump_start_time = Time.get_ticks_msec()
	
	# Detect when jump button is released
	if Input.is_action_just_released("ui_accept"):
		is_jump_button_held = false

func handle_jumping(_delta):
	# Safe physics check
	if not can_use_physics():
		return
	
	# Execute jump if conditions are met
	var can_jump = (is_on_floor() or coyote_timer > 0) and jump_buffer_timer > 0
	
	if can_jump:
		# Calculate how long jump button was held
		var hold_time = (Time.get_ticks_msec() - jump_start_time) / 1000.0
		var was_held = hold_time > 0.05 and is_jump_button_held
		
		# Castlevania-style variable jump height
		if was_held and hold_time < max_jump_hold_time:
			velocity.y = jump_velocity  # Full jump
		else:
			velocity.y = short_jump_velocity  # Short hop
		
		jump_buffer_timer = 0
		coyote_timer = 0
		is_jump_button_held = false
signal health_updated(current_health, max_health)

# Your health functions should EMIT this signal:
func take_damage(amount):
	current_health -= amount
	current_health = max(0, current_health)
	health_updated.emit(current_health, max_health)  # ← This line is crucial!
	
	if current_health <= 0:
		die()

func heal(amount):
	current_health += amount
	current_health = min(current_health, max_health)
	health_updated.emit(current_health, max_health)  # ← This line too!

func increase_max_health(amount: int):
	max_health += amount
	current_health += amount
	health_updated.emit(current_health, max_health)  # ← And this one!

func increase_max_health_no_heal(amount: int):
	max_health += amount
	health_updated.emit(current_health, max_health)  # ← And this one!
	
# Player.gd - Add these functions
func die():
	print("Player died! Showing game over screen...")
	global_position = Vector2.ZERO
	GameManager.current_room_coords = Vector2i(0, 0)
	# Freeze the game
	get_tree().paused = true
	print("Player died! Respawning...")
	
	# Stop the playtime timer
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").stop_playtime_timer()

	
	print("Player respawned")
	# Show simple game over screen without needing a separate scene
	show_simple_game_over_screen()



	
func show_simple_game_over_screen():
	# Create game over elements programmatically
	var game_over_layer = CanvasLayer.new()
	game_over_layer.name = "GameOverLayer"
	
	# Dark background
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.8)  # Semi-transparent black
	background.size = get_viewport().get_visible_rect().size
	game_over_layer.add_child(background)
	
	# Game over text
	var game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_label.add_theme_font_size_override("font_size", 60)
	game_over_label.modulate = Color.WEB_GRAY
	game_over_label.position = Vector2(0, get_viewport().get_visible_rect().size.y / 2 - 80)  # Moved up a bit
	game_over_label.size = Vector2(get_viewport().get_visible_rect().size.x, 100)
	
	var custom_font = FontFile.new()
	custom_font = load("res://Fonts/ARCADECLASSIC.TTF")
	game_over_label.add_theme_font_override("font", custom_font)
	background.add_child(game_over_label)
	
	# === NEW: Playtime Display ===
	var playtime_label = Label.new()
	playtime_label.name = "PlaytimeLabel"
	playtime_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	playtime_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	playtime_label.add_theme_font_size_override("font_size", 36)
	playtime_label.modulate = Color.LIGHT_GRAY
	playtime_label.position = Vector2(0, get_viewport().get_visible_rect().size.y / 2 - 10)  # Position below GAME OVER
	playtime_label.size = Vector2(get_viewport().get_visible_rect().size.x, 40)
	playtime_label.add_theme_font_override("font", custom_font)
	background.add_child(playtime_label)
	
	# Update playtime text
	update_playtime_display(playtime_label)
	
	# Countdown text
	var countdown_label = Label.new()
	countdown_label.text = "Returning to main menu in 5 seconds..."
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_label.add_theme_font_size_override("font_size", 30)
	countdown_label.position = Vector2(0, get_viewport().get_visible_rect().size.y / 2 + 50)  # Adjusted position
	countdown_label.size = Vector2(get_viewport().get_visible_rect().size.x, 50)
	countdown_label.add_theme_font_override("font", custom_font)
	background.add_child(countdown_label)
	
	# Timer for countdown
	var timer = Timer.new()
	timer.wait_time = 5
	timer.one_shot = true
	timer.autostart = true
	game_over_layer.add_child(timer)
	start_game_over_countdown(game_over_layer)
	
	# Add to scene
	get_tree().root.add_child(game_over_layer)

# === NEW FUNCTION: Update Playtime Display ===
func update_playtime_display(playtime_label: Label):
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		var playtime = 0.0
		
		# Get playtime using whichever method your GameManager has
		if game_manager.has_method("get_current_playtime"):
			playtime = game_manager.get_current_playtime()
		elif game_manager.has_method("get_playtime"):
			playtime = game_manager.get_playtime()
		elif game_manager.has_property("playtime"):
			playtime = game_manager.playtime
		
		# Format the time
		var minutes = int(playtime) / 60
		var seconds = int(playtime) % 60
		var milliseconds = int((playtime - int(playtime)) * 100)
		
		# Update the label
		playtime_label.text = "Time: %02d:%02d.%02d" % [minutes, seconds, milliseconds]
	else:
		playtime_label.text = "Time: 00:00.00"


func start_game_over_countdown(game_over_layer):
	# Store the scene tree reference BEFORE waiting
	var scene_tree = get_tree()
	
	# Wait for 5 seconds
	await get_tree().create_timer(5.0).timeout
	
	print("Game over countdown finished")
	
	# Clean up the game over layer
	if is_instance_valid(game_over_layer):
		game_over_layer.queue_free()
	
	# Use the stored scene tree reference
	if scene_tree and is_instance_valid(scene_tree):
		scene_tree.paused = false
		# Use call_deferred to be safe
		scene_tree.call_deferred("change_scene_to_file", "res://scenes/Area1/MainMenu.tscn")
	else:
		# Fallback - the scene tree is gone, we need to handle this differently
		print("ERROR: Scene tree is no longer available")
		# You might need to implement a different restart mechanism


func reset_player():
	# Reset player state
	current_health = max_health
	# Add any other reset logic here


func handle_room_transition():
	var player_x = global_position.x
	var screen_width = 640
	
	if player_x > screen_width:
		GameManager.change_room(Vector2i.RIGHT)
	elif player_x < 0:
		GameManager.change_room(Vector2i.LEFT)

# NEW: Safe physics check function
func can_use_physics():
	return physics_ready and is_inside_tree() and get_world_2d() != null
