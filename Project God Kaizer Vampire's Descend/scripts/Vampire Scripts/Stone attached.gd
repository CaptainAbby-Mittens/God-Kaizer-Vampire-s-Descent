extends "res://scripts/Vampire Scripts/StoneVampire.gd"

@export var rock_damage: int = 30
@export var rock_speed: float = 300.0
@export var throw_cooldown: float = 4.0
@export var patrol_distance: float = 50.0
@export var patrol_speed: float = 40.0
var can_throw: bool = true
var patrol_origin_x: float
var patrol_direction: int = 1
var is_chasing: bool = false
func _ready():
	super._ready()
	patrol_origin_x = global_position.x
	
	if not throw_timer:
		throw_timer = Timer.new()
		add_child(throw_timer)
	throw_timer.wait_time = throw_cooldown
	throw_timer.one_shot = false
	throw_timer.timeout.connect(_on_throw_timeout)
	throw_timer.start()

func _physics_process(delta):
	if current_state == State.DEAD:
		return
	apply_gravity(delta)

	player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		_patrol(delta)
		return

	var horizontal_distance = abs(player.global_position.x - global_position.x)
	var vertical_distance = abs(player.global_position.y - global_position.y)

	if horizontal_distance <= detection_range and vertical_distance <= 40:
		# Player detected: chase/throw mode
		is_chasing = true
		sprite.scale.x = 1 if player.global_position.x > global_position.x else -1
		velocity.x = 0
		if can_throw:
			throw_rock()
	else:
		is_chasing = false
		_patrol(delta)

	move_and_slide()

func _patrol(delta: float) -> void:
	# Move back and forth between patrol_origin_x ± patrol_distance
	var left_limit = patrol_origin_x - patrol_distance
	var right_limit = patrol_origin_x + patrol_distance

	velocity.x = patrol_speed * patrol_direction
	sprite.scale.x = patrol_direction

	# Flip direction if we reach the patrol boundary
	if global_position.x <= left_limit:
		patrol_direction = 1
	elif global_position.x >= right_limit:
		patrol_direction = -1

	sprite.play("Chasing")

func throw_rock():
	if not rock_scene:
		print("⚠ No rock_scene assigned in inspector!")
		return

	can_throw = false
	sprite.play("Attack")
	await get_tree().create_timer(0.3).timeout  # small delay for animation sync

	var rock = rock_scene.instantiate()
	get_tree().current_scene.add_child(rock)

	# place the rock slightly in front of the vampire
	rock.global_position = global_position + Vector2(sprite.scale.x * 16, 30) 

	# set direction based on facing
	if "direction" in rock:
		rock.direction = 1 if sprite.scale.x > 0 else -1

	if "speed" in rock:
		rock.speed = rock_speed
	if "damage" in rock:
		rock.damage = rock_damage

	throw_timer.start()

func _on_throw_timeout():
	can_throw = true
