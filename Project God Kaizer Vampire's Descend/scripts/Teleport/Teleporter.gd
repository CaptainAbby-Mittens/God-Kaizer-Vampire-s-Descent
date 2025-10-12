extends Area2D

@export var target_scene_path: String = ""
@export var target_position: Vector2 = Vector2.ZERO
@export var teleporter_id: String = ""

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Teleporting player to: ", target_scene_path)
		# Use call_deferred to avoid physics callback issues
		call_deferred("_deferred_teleport", body)

func _deferred_teleport(body):
	if target_scene_path.is_empty():
		# Teleport within same scene
		body.global_position = target_position
	else:
		# Change to different scene - use GameManager for coordinate-based teleportation
		var game_manager = get_node("/root/GameManager")
		if game_manager:
			# Calculate direction based on teleporter position vs current room
			var direction = Vector2i(7,0)  # Default direction
			game_manager.change_room(direction)
