extends StaticBody2D

func _ready():
	print("Platform ready and waiting for player...")
	# Connect to the Area2D child's signal
	$KeyTrigger.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player touched platform.")
		if GameManager.has_key4:
			print("Player has key, platform disappearing!")
			queue_free()
		else:
			print("Player does not have key.")
