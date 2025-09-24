# BasePotion.gd
extends Area2D

@export var potion_type: String = "unknown"
@export var respawn_on_restart: bool = true

# Use CollisionPolygon2D instead of CollisionShape2D
@onready var visual_node = _find_visual_node()
@onready var collision = $CollisionPolygon2D  # Changed to CollisionPolygon2D

var is_active: bool = true

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("potions")
	
	if collision:
		collision_layer = 2
		collision_mask = 1
	else:
		push_error("CollisionPolygon2D not found in potion: " + name)
	
	print("Potion ready: ", potion_type, " | Visual: ", visual_node.name if visual_node else "None", " | Collision: ", collision.name if collision else "None")

func _find_visual_node():
	# Look for any visual node
	for child in get_children():
		if child is Sprite2D or child is AnimatedSprite2D or child is ColorRect:
			return child
	print("No visual node found for potion: ", name)
	return null

func _on_body_entered(body):
	if not is_active:
		return
	
	if body.is_in_group("player"):
		apply_effect(body)
		collect_potion()

func apply_effect(_player):
	# Override this in child classes
	print("Base potion effect - should be overridden")

func collect_potion():
	is_active = false
	if visual_node:
		visual_node.visible = false
	if collision:
		collision.set_deferred("disabled", true)
	print(potion_type, " potion collected")

func respawn_potion():
	is_active = true
	if visual_node:
		visual_node.visible = true
	if collision:
		collision.set_deferred("disabled", false)
	print(potion_type, " potion respawned")
