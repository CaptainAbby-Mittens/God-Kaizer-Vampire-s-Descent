extends Area2D

@export var weapon_name: String = "Sword"
@export var damage: int = 30
@export var attack_speed: float = 1.0

var damaged_enemies: Array = []
var current_weapon = null
var current_weapon_path: String = ""
var is_attacking: bool = false
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
	if is_attacking or not is_equipped:
		return
	
	is_attacking = true
	damaged_enemies.clear()  # Reset hit enemies for new attack
	
	if has_node("AnimationPlayer") and $AnimationPlayer.has_animation("swing"):
		$AnimationPlayer.play("swing")
	else:
		is_attacking = false

func start_attack():
	# Called when attack animation starts
	can_damage = true
	print("Weapon can now damage enemies")
	
	# Debug: Check what enemies are in range
	var overlapping = get_overlapping_bodies()
	print("Overlapping bodies at attack start: ", overlapping)

func end_attack():
	# Called when attack animation ends
	can_damage = false
	is_attacking = false
	print("Weapon can no longer damage enemies")

func equip_to_player(player):
	print("Weapon: Successfully equipped to player")
	is_equipped = true
	
	# Make sure sprite is visible but weapon starts hidden
	if has_node("Sprite2D"):
		$Sprite2D.visible = true
	
	# Weapon starts HIDDEN (only shows during swing)
	visible = false
	
	# Ensure collision is enabled for attack detection
	if has_node("CollisionPolygon2D"):
		$CollisionPolygon2D.disabled = false

# Debug function to visualize collision during development
func _draw():
	if Engine.is_editor_hint() and has_node("CollisionPolygon2D"):
		var col = $CollisionPolygon2D
		var polygon = col.polygon
		var color = Color.RED
		
		for i in range(polygon.size()):
			var point = polygon[i]
			var next_point = polygon[(i + 1) % polygon.size()]
			draw_line(point, next_point, color, 2.0)

# Debug process to see positions
func _process(delta):
	if is_attacking:
		print("Sword Global Position: ", global_position)
		print("Collision Global Position: ", $CollisionPolygon2D.global_position)
		print("Sprite Global Position: ", $Sprite2D.global_position)
