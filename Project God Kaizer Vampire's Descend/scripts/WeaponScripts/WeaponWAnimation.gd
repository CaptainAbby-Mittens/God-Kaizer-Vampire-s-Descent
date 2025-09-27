extends Area2D

@export var weapon_name: String = "Sword"
@export var damage: int = 30
@export var attack_speed: float = 1.0
var current_weapon = null
var current_weapon_path: String = ""
var is_equipped: bool = false
var can_damage: bool = false  # Only damage during active attack frames

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	collision_layer = 2  # Weapon layer
	collision_mask = 1 | 4  # Player layer (1) and Enemy layer (4)
	
	# Add to weapon group
	add_to_group("weapon")

func _on_area_entered(area):
	if can_damage and area.get_parent().is_in_group("enemy"):
		var enemy = area.get_parent()
		print("Sword hit enemy: ", enemy.name)
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
			# Optional: add knockback or other effects
func _on_body_entered(body):
	if can_damage and body.is_in_group("enemy"):
		print("Sword hit enemy: ", body.name)
		if body.has_method("take_damage"):
			body.take_damage(damage)
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
func attack():
	if current_weapon:
		print("Attacking with weapon")
		
		# Make weapon visible
		current_weapon.visible = true
		
		# ENABLE DAMAGE HERE
		if current_weapon.has_method("start_attack"):
			current_weapon.start_attack()
		
		# Get AnimationPlayer and play swing animation
		var animation_player = current_weapon.get_node("AnimationPlayer")
		if animation_player:
			animation_player.play("Swing")
			print("Playing Swing animation")
			
			# Wait for animation to finish then hide weapon and disable damage
			await animation_player.animation_finished
			current_weapon.visible = false
			if current_weapon.has_method("end_attack"):
				current_weapon.end_attack()
	else:
		print("No weapon equipped")
func start_attack():
	# Called when attack animation starts
	can_damage = true
	print("Weapon can now damage enemies")
	collision_mask = 1 | 4  
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
