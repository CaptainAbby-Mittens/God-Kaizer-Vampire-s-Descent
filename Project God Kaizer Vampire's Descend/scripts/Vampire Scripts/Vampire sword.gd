extends CharacterBody2D

@export var max_health: int = 50
@export var damage: int = 20
@export var move_speed: float = 80.0
@export var attack_range: float = 60.0
@export var detection_range: float = 400.0
@export var contact_damage_cooldown: float = 1.0   # cooldown between collision damage
@onready var sprite = $Sprite2D

var current_health: int
var player: Node2D
var is_player_detected: bool = false
var can_attack: bool = true
var attack_cooldown: float = 1.5
var can_deal_contact_damage: bool = true

enum State { IDLE, CHASING, ATTACKING, DEAD }
var current_state: State = State.IDLE

func _ready():
	current_health = max_health
	collision_layer = 4  # Enemies layer
	collision_mask = 1 | 2  # Collides with player (1) + weapons (2)
	add_to_group("enemy")

	# Weapon hit detection
	if has_node("HitDetectionArea"):
		var hit_area = $HitDetectionArea
		hit_area.monitoring = true
		hit_area.monitorable = true
		hit_area.area_entered.connect(_on_hit_detection_area_entered)
		# NEW: also check overlaps every frame
		set_physics_process(true)

	# Player collision detection (enemy body hitting player)
	if has_node("CollisionShape2D"):
		var shape = $CollisionShape2D
		if shape.get_parent() == self:
			var area = Area2D.new()
			area.name = "ContactDamageArea"
			add_child(area)
			var new_shape = CollisionShape2D.new()
			new_shape.shape = shape.shape
			area.add_child(new_shape)
			area.monitoring = true
			area.collision_layer = 0
			area.collision_mask = 1  # only detect player
			area.area_entered.connect(_on_contact_area_entered)

	current_state = State.IDLE
	update_sprite_frame()


# ---------------- SIGNAL HANDLERS ---------------- #

func _on_hit_detection_area_entered(area):
	if area.is_in_group("weapon") and area.has_method("get_damage"):
		take_damage(area.get_damage())

func _on_contact_area_entered(area: Area2D):
	if not can_deal_contact_damage:
		return
	if area.is_in_group("player") and area.has_method("take_damage"):
		area.take_damage(damage)
		print("Enemy collided with player for ", damage, " damage!")
		# start cooldown so the player doesn’t take damage every physics frame
		can_deal_contact_damage = false
		_start_contact_cooldown()


# ---------------- STATE MACHINE ---------------- #

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
	if has_node("HitDetectionArea"):
		for area in $HitDetectionArea.get_overlapping_areas():
			if area.is_in_group("weapon") and area.has_method("get_damage"):
				take_damage(area.get_damage())

func idle_state(_delta):
	player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		if distance <= detection_range:
			current_state = State.CHASING
			update_sprite_frame()

func chasing_state(delta):
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		if direction.x != 0:
			sprite.scale.x = 1 if direction.x > 0 else -1
		velocity = direction * move_speed
		move_and_slide()
		if global_position.distance_to(player.global_position) <= attack_range and can_attack:
			current_state = State.ATTACKING
			update_sprite_frame()
			attack()

func attacking_state(_delta):
	velocity = Vector2.ZERO

func dead_state(_delta):
	velocity = Vector2.ZERO


# ---------------- ATTACK & DAMAGE ---------------- #

func attack():
	if not can_attack:
		return
	can_attack = false

	if player and global_position.distance_to(player.global_position) <= attack_range * 1.2:
		if player.has_method("take_damage"):
			player.take_damage(damage)
			print("Enemy attacked player for ", damage, " damage!")

	await get_tree().create_timer(attack_cooldown).timeout

	if player and is_instance_valid(player) and global_position.distance_to(player.global_position) <= detection_range:
		current_state = State.CHASING
	else:
		current_state = State.IDLE
	update_sprite_frame()
	can_attack = true

func take_damage(amount):
	current_health -= amount
	print("Vampire took ", amount, " damage! Health: ", current_health)
	if current_health <= 0:
		die()

func die():
	current_state = State.DEAD
	update_sprite_frame()
	collision_layer = 0
	collision_mask = 0
	queue_free()

func _exit_tree():
	if has_node("HitDetectionArea"):
		var hit_area = $HitDetectionArea
		if hit_area.area_entered.is_connected(_on_hit_detection_area_entered):
			hit_area.area_entered.disconnect(_on_hit_detection_area_entered)
	remove_from_group("enemy")
	player = null


# ---------------- HELPERS ---------------- #

func update_sprite_frame():
	if not (sprite is Sprite2D):
		return
	match current_state:
		State.IDLE: sprite.frame = 0
		State.CHASING: sprite.frame = 1
		State.ATTACKING: sprite.frame = 2
		State.DEAD: sprite.frame = 3

func _start_contact_cooldown():
	await get_tree().create_timer(contact_damage_cooldown).timeout
	can_deal_contact_damage = true
