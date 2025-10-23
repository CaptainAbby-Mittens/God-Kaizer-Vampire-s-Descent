extends StaticBody2D

func _ready():
	print("Platform ready and waiting for player...")
	# Connect to the Area2D child's signal
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		queue_free()
