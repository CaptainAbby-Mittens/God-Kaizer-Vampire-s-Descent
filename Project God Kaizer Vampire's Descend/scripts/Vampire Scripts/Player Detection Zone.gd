# PlayerDetectionZone.gd
extends Area2D

var player: Node2D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set up collision
	collision_layer = 0
	collision_mask = 1  # Detect player layer

func _on_body_entered(body):
	if body.is_in_group("player"):
		player = body
		print("Player detected!")

func _on_body_exited(body):
	if body == player:
		player = null
		print("Player lost!")

func can_see_player() -> bool:
	return player != null and is_instance_valid(player)
