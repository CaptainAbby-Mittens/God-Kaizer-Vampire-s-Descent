# EnemyBase.gd
extends CharacterBody2D

@export var max_health: int = 50
@export var damage: int = 20
@export var move_speed: float = 80.0
@export var attack_range: float = 60.0
@export var detection_range: float = 400.0
@onready var sprite = $Sprite2D

var current_health: int
var player: Node2D
var is_player_detected: bool = false
var can_attack: bool = true
var attack_cooldown: float = 1.5

enum State { IDLE, CHASING, ATTACKING, DEAD }
var current_state: State = State.IDLE

func _ready():
	current_health = max_health
	collision_layer = 2  # Enemies layer
	collision_mask = 1   # Player layer
	
	# Start in idle state with idle frame
	current_state = State.IDLE
	update_sprite_frame()

func _physics_process(delta):
	match current_state:
		State.IDLE:
			idle_state(delta)
		State.CHASING:
			chasing_state(delta)
		State.ATTACKING:
			attacking_state(delta)
		State.DEAD:
			dead_state(delta)

func idle_state(_delta):
	# Check for player using simple distance check
	player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		if distance <= detection_range:
			current_state = State.CHASING
			update_sprite_frame()

func chasing_state(delta):
	if player and is_instance_valid(player):
		# Calculate direction to player
		var direction = (player.global_position - global_position).normalized()
		
		# Flip sprite based on direction
		if direction.x != 0:
			sprite.scale.x = 1 if direction.x > 0 else -1
		
		# Move toward player
		velocity = direction * move_speed
		move_and_slide()
		
		# Check if player is in attack range
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= attack_range and can_attack:
			current_state = State.ATTACKING
			update_sprite_frame()
			attack()

func attacking_state(_delta):
	# Stop moving during attack
	velocity = Vector2.ZERO
	# Attack logic handled in attack() function

func dead_state(_delta):
	velocity = Vector2.ZERO

func attack():
	if not can_attack:
		return
	
	can_attack = false
	
	# For now, just apply damage immediately
	# Later this will be triggered by animation frames
	if player and global_position.distance_to(player.global_position) <= attack_range * 1.2:
		if player.has_method("take_damage"):
			player.take_damage(damage)
			print("Enemy attacked player for ", damage, " damage!")
	
	# Wait for attack cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	
	# Return to chasing if player still visible
	if player and is_instance_valid(player) and global_position.distance_to(player.global_position) <= detection_range:
		current_state = State.CHASING
		update_sprite_frame()
	else:
		current_state = State.IDLE
		update_sprite_frame()
	
	can_attack = true

func update_sprite_frame():
	# Simple frame switching - you'll replace this with animations later
	match current_state:
		State.IDLE:
			# Set to idle frame (frame 0 or whatever your idle frame is)
			if sprite is Sprite2D:
				sprite.frame = 0
		State.CHASING:
			# Set to walking frame (frame 1 or whatever your walking frame is)
			if sprite is Sprite2D:
				sprite.frame = 1
		State.ATTACKING:
			# Set to attack frame (frame 2 or whatever your attack frame is)
			if sprite is Sprite2D:
				sprite.frame = 2
		State.DEAD:
			# Set to dead frame
			if sprite is Sprite2D:
				sprite.frame = 3

func take_damage(amount: int):
	current_health -= amount
	print("Enemy took ", amount, " damage. Health: ", current_health)
	
	# Flash effect when hit
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if current_health <= 0:
		die()

func die():
	current_state = State.DEAD
	update_sprite_frame()
	collision_layer = 0  # Disable collisions
	collision_mask = 0
	
	# Wait a moment then remove
	await get_tree().create_timer(1.0).timeout
	queue_free()
