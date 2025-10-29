extends Area2D

@export var weapon_name: String = "Sword"
@export var damage: int = 0
@export var attack_speed: float = 1.0
@export var show_collision_debug: bool = true
@export var debug_color: Color = Color(1, 0, 0, 0.5)
var damaged_enemies: Array = []
var current_weapon = null
var current_weapon_path: String = ""
var is_attacking: bool = false
var is_equipped: bool = false
var can_damage: bool = false  # Only damage during active attack frames

# Store references to nodes
@onready var sprite = $Sprite2D
@onready var collision_polygon = $CollisionPolygon2D
@onready var animation_player = $AnimationPlayer



func equip_to_player(_player):
	print("Weapon: Successfully equipped to player")
	is_equipped = true
	
	# Make sure sprite is visible but weapon starts hidden
	if sprite:
		sprite.visible = true
	
	# Weapon starts HIDDEN (only shows during swing)
	visible = false
	
	# Ensure collision is enabled for attack detection
	if collision_polygon:
		collision_polygon.disabled = false
func update_weapon_position(new_position: Vector2):
	if sprite:
		sprite.position = new_position
	if collision_polygon:
		collision_polygon.position = new_position

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
			body.take_damage(damage* GameManager.crit_strike())
	if body.is_in_group("player") and not is_equipped:
		var player = body
		if player.has_method("equip_weapon"):
			print("Weapon: Picked up by player")
			is_equipped = true
		
			# Hide the pickup weapon immediately
			if sprite:
				sprite.visible = false
			
			# Disable collision using set_deferred
			if collision_polygon:
				collision_polygon.set_deferred("disabled", true)
			
			# Call equip_weapon on the player
			player.equip_weapon(self)

func attack():
	if is_attacking or not is_equipped:
		return
	
	is_attacking = true
	damaged_enemies.clear()  # Reset hit enemies for new attack
	
	# Make weapon visible
	visible = true
	if sprite:
		sprite.visible = true
	
	# Enable collision
	if collision_polygon:
		collision_polygon.disabled = false
	
	if animation_player and animation_player.has_animation("swing"):
		animation_player.play("swing")
	else:
		is_attacking = false
func check_existing_overlaps():
	if can_damage:
		# Check areas (like enemy attack areas)
		var areas = get_overlapping_areas()
		for area in areas:
			if area.get_parent().is_in_group("enemy"):
				var enemy = area.get_parent()
				print("Sword hit overlapping enemy: ", enemy.name)
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)
			if area.get_parent().is_in_group("destructible"):
				area.queue_free()
			
		
		# Check bodies (enemy physics bodies)
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("enemy"):
				print("Sword hit overlapping enemy: ", body.name)
				if body.has_method("take_damage"):
					body.take_damage(damage)
			if body.is_in_group("destructible"):
				body.queue_free()
			

func start_attack():
	# Called when attack animation starts
	can_damage = true
	print("Weapon can now damage enemies")
	
	# Force update collision position

	check_existing_overlaps()
	# Debug: Check what enemies are in range
	var overlapping = get_overlapping_bodies()
	print("Overlapping bodies at attack start: ", overlapping)
	
func end_attack():
	# Called when attack animation ends
	can_damage = false
	is_attacking = false
	print("Weapon can no longer damage enemies")
	
	# Hide weapon after attack
	visible = false


# Debug process to see positions and force collision to follow sprite
func _process(_delta):
	damage = GameManager.player_damage
	if is_attacking:
	
		
		# Debug info
		if collision_polygon and sprite:
			print("Sprite position: ", sprite.position)
			print("Collision position: ", collision_polygon.position)
			print("Sprite rotation: ", sprite.rotation)
			print("Collision rotation: ", collision_polygon.rotation)
	
	# Always redraw debug when showing collision
	if show_collision_debug or is_attacking:
		queue_redraw()
