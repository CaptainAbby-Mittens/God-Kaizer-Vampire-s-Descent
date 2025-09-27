# Weapon.gd - Single script for all weapons
extends Area2D

@export_category("Weapon Properties")
@export var weapon_name: String = "Weapon"
@export var damage: int = 40
@export var attack_speed: float = 1.0
@export var weapon_range: float = 80.0
@export var weapon_type: String = "sword"  # sword, axe, spear, etc.

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

var is_equipped: bool = false
var current_owner: Node2D = null

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("weapons")
	
	if collision:
		collision_layer = 2
		collision_mask = 1
	
	print("Weapon ready: ", weapon_name)

func _on_body_entered(body):
	if body.is_in_group("player") and not is_equipped:
		pick_up(body)

func pick_up(player):
	print("Picking up weapon: ", weapon_name)
	current_owner = player
	is_equipped = true
	
	if collision:
		collision.set_deferred("disabled", true)
	if sprite:
		sprite.visible = false
	
	if player.has_method("equip_weapon"):
		player.equip_weapon(self)

func attack():
	if not is_equipped or not current_owner:
		return
	
	print(weapon_name, " attacking!")
	play_attack_animation()
	
	# Damage enemies in range
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.global_position.distance_to(global_position) <= weapon_range:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)

func play_attack_animation():
	if sprite is Sprite2D:
		# Simple 3-frame animation
		for frame in range(3):
			sprite.frame = frame
			await get_tree().create_timer(0.1).timeout
		sprite.frame = 0

func get_weapon_data() -> Dictionary:
	return {
		"name": weapon_name,
		"damage": damage,
		"attack_speed": attack_speed,
		"range": weapon_range,
		"type": weapon_type
	}
func get_damage():
	return damage
