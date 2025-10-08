extends Area2D

func _ready():
	print("Platform ready and waiting for player...")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player touched platform.")
		if body.has_key:
			print("Player has key, platform disappearing!")
			queue_free()
		else:
			print("Player does not have key.")
