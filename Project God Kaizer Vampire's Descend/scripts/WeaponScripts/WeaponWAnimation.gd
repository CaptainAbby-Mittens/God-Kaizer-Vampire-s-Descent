extends Area2D

@export var weapon_name: String = "Sword"
@export var damage: int = 30
@export var attack_speed: float = 1.0

var is_equipped: bool = false
var can_damage: bool = false  # Only damage during active attack frames

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)  # Connect area entered for enemy detection
	collision_layer = 2
	collision_mask = 1 | 4  # Layer 1 (player) and layer 4 (enemies)

func _on_area_entered(area):
	# This detects when weapon hits enemy areas
	if can_damage:
		print("Weapon hit area: ", area.name)
		print("Area is in enemy group? ", area.is_in_group("enemy"))
		print("Area's parent: ", area.get_parent().name)
		
		# Check if area or its parent is an enemy
		var enemy = null
		if area.is_in_group("enemy"):
			enemy = area
		elif area.get_parent().is_in_group("enemy"):
			enemy = area.get_parent()
		
		if enemy:
			print("Weapon hit enemy: ", enemy.name)
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
				print("Dealt ", damage, " damage to vampire")
			else:
				print("Enemy missing take_damage method")
func _on_body_entered(body):
	if body.is_in_group("player") and not is_equipped:
		var player = body
		if player.has_method("equip_weapon"):
			print("Weapon: Picked up by player")
			is_equipped = true
			
			# Hide the pickup weapon immediately
			if has_node("Sprite2D"):
				$Sprite2D.visible = false
			
			# Disable collision using set_deferred
			if has_node("CollisionShape2D"):
				$CollisionShape2D.set_deferred("disabled", true)
			
			# Call equip_weapon on the player
			player.equip_weapon(self)

func start_attack():
	# Called when attack animation starts
	can_damage = true
	print("Weapon can now damage enemies")

func end_attack():
	# Called when attack animation ends
	can_damage = false
	print("Weapon can no longer damage enemies")

func equip_to_player(player):
	print("Weapon: Successfully equipped to player")
	is_equipped = true
	
	# Make sure sprite is visible but weapon starts hidden
	if has_node("Sprite2D"):
		$Sprite2D.visible = true
	
	# Weapon starts HIDDEN (only shows during swing)
	visible = false
	
	# Ensure collision is disabled for pickup, but enabled for attack detection
	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = false  # Enable for attack detection
		$CollisionShape2D.set_collision_layer_value(1, false)  # Disable player layer
		$CollisionShape2D.set_collision_mask_value(1, false)   # Disable player mask
		$CollisionShape2D.set_collision_mask_value(4, true)    # Enable enemy mask
