# WeaponWAnimation.gd
extends Area2D

@export var weapon_name: String = "Sword"
@export var damage: int = 30
@export var attack_speed: float = 1.0
@export var weapon_range: float = 80.0

# Correct node paths for your structure
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var collision = $CollisionShape2D  # ← Direct child of Area2D

var is_equipped: bool = false
var current_owner: Node2D = null
var is_attacking: bool = false

func _ready():
	# Debug node detection
	print("Weapon loading: ", weapon_name)
	print("Sprite2D found: ", sprite != null)
	print("AnimationPlayer found: ", animation_player != null) 
	print("CollisionShape2D found: ", collision != null)
	
	# Only setup if nodes exist
	if collision:
		body_entered.connect(_on_body_entered)
		add_to_group("weapons")
		collision_layer = 2
		collision_mask = 1
	else:
		push_error("CollisionShape2D not found in weapon: " + name)

func _on_body_entered(body):
	if body.is_in_group("player") and not is_equipped:
		pick_up(body)

func pick_up(player):
	print("Picking up: ", weapon_name)
	current_owner = player
	is_equipped = true
	
	if collision:
		collision.set_deferred("disabled", true)
	if sprite:
		sprite.visible = false
	
	if player.has_method("equip_weapon"):
		player.equip_weapon(self)

func attack():
	if not is_equipped or is_attacking:
		return
	
	is_attacking = true
	print(weapon_name, " attacking!")
	
	play_attack_animation()
	
	# Damage enemies in range
	apply_damage_to_enemies()

func play_attack_animation():
	if animation_player and animation_player.has_animation("attack"):
		animation_player.play("attack")
		await animation_player.animation_finished
		is_attacking = false
	else:
		print("Attack animation not found!")
		is_attacking = false

func apply_damage_to_enemies():
	if not is_equipped or not current_owner:
		return
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(global_position) <= weapon_range:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
				print("Hit enemy for ", damage, " damage!")

func get_weapon_data() -> Dictionary:
	return {
		"name": weapon_name,
		"damage": damage,
		"attack_speed": attack_speed,
		"range": weapon_range
	}
