extends CharacterBody2D

# === CASTLEVANIA-STYLE MOVEMENT PARAMETERS ===
@export var max_walk_speed = 160.0        # Soma walks fairly slow
@export var walk_acceleration = 4000.0     # Crisp but not instant acceleration
@export var ground_friction = 1000.0       # Slight slide when stopping

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

func _ready():
	# Wait until physics is properly set up
	await get_tree().physics_frame
	physics_ready = true
	current_health = max_health
	health_updated.emit(current_health, max_health)
	
	add_to_group("player")
func _physics_process(delta):
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
	game_over_label.position = Vector2(0, get_viewport().get_visible_rect().size.y / 2 - 50)
	game_over_label.size = Vector2(get_viewport().get_visible_rect().size.x, 100)
	
	var custom_font = FontFile.new()
	custom_font = load("res://Fonts/ARCADECLASSIC.TTF")  # Adjust path to your font file
	game_over_label.add_theme_font_override("font", custom_font)
	background.add_child(game_over_label)
	
	# Countdown text
	var countdown_label = Label.new()
	countdown_label.text = "Returning to main menu in 5 seconds..."
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_label.add_theme_font_size_override("font_size", 30)
	countdown_label.position = Vector2(0, get_viewport().get_visible_rect().size.y / 2 + 20)
	countdown_label.size = Vector2(get_viewport().get_visible_rect().size.x, 50)
	countdown_label.add_theme_font_override("font", custom_font)
	background.add_child(countdown_label)
	
	# Timer for countdown
	var timer = Timer.new()
	timer.wait_time = 5
	timer.one_shot = true
	timer.autostart = true  # ← This will auto-start when added to scene
	game_over_layer.add_child(timer)
	start_game_over_countdown(game_over_layer)
	# Add to scene
	get_tree().root.add_child(game_over_layer)


func start_game_over_countdown(game_over_layer):
	# Wait for 2 seconds
	await get_tree().create_timer(2.0).timeout
	print("2 seconds elapsed, returning to menu")
	
	# Clean up and return to menu
	game_over_layer.queue_free()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Area1/MainMenu.tscn")
	reset_player()


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


func _input(event):
	# Test damage with number keys
	if Input.is_key_pressed(KEY_1):  # Press 1
		take_damage(10)
	
	if Input.is_key_pressed(KEY_2):  # Press 2
		take_damage(25)
	
	if Input.is_key_pressed(KEY_3):  # Press 3
		take_damage(50)
	
	# Test healing with number keys
	if Input.is_key_pressed(KEY_4):  # Press 4
		heal(10)
	
	if Input.is_key_pressed(KEY_5):  # Press 5
		heal(25)
	
	if Input.is_key_pressed(KEY_6):  # Press 6
		heal(50)
	
	# Test max health increase
	if Input.is_key_pressed(KEY_7):  # Press 7
		increase_max_health(25)
	
	if Input.is_key_pressed(KEY_8):  # Press 8
		increase_max_health(50)
	
	if Input.is_key_pressed(KEY_9):  # Press 9
		increase_max_health_no_heal(25)
	
