# WeaponWAnimation.gd
extends Area2D

@export var weapon_name: String = "Sword"
@export var damage: int = 30
@export var attack_speed: float = 1.0

var is_equipped: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	collision_layer = 2
	collision_mask = 1

func _on_body_entered(body):
	print("Weapon: Body entered - ", body.name)
	
	if body.is_in_group("player") and not is_equipped:
		print("Weapon: Attempting pickup")
		# Use call_deferred to avoid physics errors
		call_deferred("pick_up", body)

func pick_up(player):
	print("Weapon: Starting pickup process")
	is_equipped = true
	
	# Disable collision with set_deferred
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
		print("Weapon: Collision disabled")
	
	# Hide the sprite
	if has_node("Sprite2D"):
		$Sprite2D.visible = false
		print("Weapon: World sprite hidden")
	
	# Call player's equip method with call_deferred
	if player.has_method("equip_weapon"):
		print("Weapon: Calling player.equip_weapon()")
		player.call_deferred("equip_weapon", self)
	else:
		print("ERROR: Player missing equip_weapon method!")
