# WeaponWAnimation.gd - Corrected version
extends Area2D

@export var weapon_name: String = "Sword"
@export var damage: int = 30
@onready var sprite = $Sprite2D
var is_equipped: bool = false

func _ready():
	# Connect signals
	body_entered.connect(_on_body_entered)
	
	# Set collision layers
	collision_layer = 2  # Pickup layer
	collision_mask = 1   # Player layer
	
	print("Weapon ready: ", weapon_name)

func _on_body_entered(body):
	print("Weapon: Body entered - ", body.name)
	
	if body.is_in_group("player") and not is_equipped:
		print("Weapon: Attempting pickup")
		pick_up(body)

func pick_up(player):
	print("Picking up: ", weapon_name)
	is_equipped = true
	
	# Disable collision but DON'T remove the node
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	# Hide the world sprite (it will be replaced by player's weapon sprite)
	if has_node("Sprite2D"):
		$Sprite2D.visible = false
	
	# Call player's equip method
	if player.has_method("equip_weapon"):
		player.equip_weapon(self)
	else:
		print("ERROR: Player missing equip_weapon method!")
