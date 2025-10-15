extends Area2D

@export var target_room_coords: Vector2i = Vector2i(1, 0)  # Use coordinates instead of scene path
@export var spawn_direction: Vector2i = Vector2i.RIGHT  # Which direction player spawns from
@export var teleporter_id: String = ""

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Teleporting player to room: ", target_room_coords)
		# Use call_deferred to avoid physics callback issues
		call_deferred("_deferred_teleport", body)

func _deferred_teleport(body):
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.teleport_to_room(target_room_coords, spawn_direction)
	else:
		print("ERROR: GameManager not found!")
