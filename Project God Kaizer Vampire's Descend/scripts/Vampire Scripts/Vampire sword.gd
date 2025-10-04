extends CharacterBody2D

@export var max_health: int = 50
@export var damage: int = 20
@export var move_speed: float = 80.0
@export var attack_range: float = 60.0
@export var detection_range: float = 400.0
@export var contact_damage_cooldown: float = 1.0
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var collider: CollisionPolygon2D = $Sprite2D/HitDetectionArea/Collider

var current_health: int
var player: Node2D
var is_player_detected: bool = false
var can_attack: bool = true
var attack_cooldown: float = 1.5
var can_deal_contact_damage: bool = true

enum State { IDLE, CHASING, ATTACKING, DEAD }
var current_state: State = State.IDLE
@onready var contact_area: Area2D = $Sprite2D/HitDetectionArea

# Pre-generated collision polygons
var frame_polys: Array = []

func _ready():
	current_health = max_health
	collision_layer = 4
	collision_mask = 1 | 2
	add_to_group("enemy")
	if contact_area and not contact_area.area_entered.is_connected(_on_contact_area_entered):
		contact_area.area_entered.connect(_on_contact_area_entered)
	if collider:
		var parent_area = collider.get_parent() as Area2D
		if parent_area:
			parent_area.monitoring = true
			parent_area.monitorable = true
			parent_area.collision_layer = 0
			parent_area.collision_mask = 1  # only detect player
			if not parent_area.area_entered.is_connected(_on_contact_area_entered):
				parent_area.area_entered.connect(_on_contact_area_entered)

	if has_node("HitDetectionArea"):
		var hit_area = $HitDetectionArea
		hit_area.monitoring = true
		hit_area.monitorable = true
		hit_area.area_entered.connect(_on_hit_detection_area_entered)
		set_physics_process(true)

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
			area.collision_mask = 1
			area.area_entered.connect(_on_contact_area_entered)

	current_state = State.IDLE
	update_sprite_frame()

	# Build collision polygons once
	generate_frame_polys()

	
	# Apply initial collision polygon
	_on_frame_changed()

# ---------------- COLLISION POLY GEN ---------------- #

func generate_frame_polys():
	frame_polys.clear()
	for anim_name in sprite.sprite_frames.get_animation_names():
		var frame_count = sprite.sprite_frames.get_frame_count(anim_name)
		for i in range(frame_count):
			var tex: Texture2D = sprite.sprite_frames.get_frame_texture(anim_name, i)
			if tex == null:
				frame_polys.append(null)
				continue

			var img: Image = tex.get_image()
			var bm := BitMap.new()
			bm.create_from_image_alpha(img, 0.1)

			var polys = bm.opaque_to_polygons(Rect2(Vector2.ZERO, Vector2(img.get_size())), 1.0)
			if polys.size() > 0:
				var poly = polys[0]
				# cast to Vector2 so subtraction works
				var half_size: Vector2 = Vector2(img.get_size()) / 2.0
				for j in range(poly.size()):
					poly[j] -= half_size
				frame_polys.append(poly)
			else:
				frame_polys.append(null)

func _on_frame_changed():
	var anim = sprite.animation
	var frame = sprite.frame
	var frame_idx = get_frame_index(anim, frame)
	if frame_idx >= 0 and frame_idx < frame_polys.size() and frame_polys[frame_idx] != null:
		collider.polygon = frame_polys[frame_idx]


func get_frame_index(anim: String, frame: int) -> int:
	var idx = 0
	for anim_name in sprite.sprite_frames.get_animation_names():
		var frame_count = sprite.sprite_frames.get_frame_count(anim_name)
		if anim_name == anim:
			return idx + frame
		idx += frame_count
	return -1


# ---------------- SIGNAL HANDLERS ---------------- #

func _on_hit_detection_area_entered(area):
	if area.is_in_group("weapon") and area.has_method("get_damage"):
		take_damage(area.get_damage())

func _on_contact_area_entered(area: Area2D):
	if not can_deal_contact_damage:
		return
	if area.is_in_group("player"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
			print("Player took ", damage, " contact damage!")
		can_deal_contact_damage = false
		_start_contact_cooldown()


func _start_contact_cooldown():
	await get_tree().create_timer(contact_damage_cooldown).timeout
	can_deal_contact_damage = true

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
	var effective_range = attack_range * 1.2

	if sprite and sprite.scale.x > 0:  # facing right
		effective_range *= 0.7
	if player and is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		
		# Only move horizontally, ignore vertical movement
		direction.y = 0
		
		if direction.x != 0 and sprite:
			sprite.scale.x = 1 if direction.x > 0 else -1
		
		velocity = direction * move_speed
		move_and_slide()
		
		if global_position.distance_to(player.global_position) <= effective_range and can_attack:
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

	var effective_range = attack_range * 0.8

	# If vampire is facing right, shrink the attack range
	if sprite and sprite.scale.x > 0:  # facing right
		effective_range *= 1.2  # reduce range (adjust this factor as needed)

	#if player and global_position.distance_to(player.global_position) <= effective_range:
		#if player.has_method("take_damage"):
			#player.take_damage(damage)
			#print("Enemy attacked player for ", damage, " damage!")

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
	match current_state:
		State.IDLE: sprite.play("Idle")
		State.CHASING: sprite.play("Chasing")
		State.ATTACKING: sprite.play("Attack")
		State.DEAD: sprite.play("Death")
