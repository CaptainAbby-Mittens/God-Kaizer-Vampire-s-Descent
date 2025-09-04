# HealthUpgrade.gd
extends Area2D

@export var health_increase: int = 25  # How much max HP to add
@export var respawn_time: float = 30.0  # Time to respawn (seconds)

func _ready():
	# Connect the area entered signal
	body_entered.connect(_on_body_entered)  
	
	# Optional: Add a gentle floating animation
	create_floating_animation()

func _on_body_entered(body):
	# Check if the colliding body is the player
	if body.is_in_group("player"):
		print("Health upgrade collected!")
		
		# Grant max HP to the player
		body.increase_max_health(health_increase)
		
		# Play collection effect
		play_collection_effect()
		
		# Hide and schedule respawn
		hide()
		$CollisionShape2D.set_deferred("disabled", true)
		get_tree().create_timer(respawn_time).timeout.connect(_on_respawn_timeout)

func play_collection_effect():
	# Play a collection sound
	# $AudioStreamPlayer2D.play()
	
	# Show a particle effect
	# $Particles2D.emitting = true
	
	# Simple scale animation
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property($Sprite2D, "scale", Vector2(0, 0), 0.2)
	tween.tween_callback(queue_free)  # Or hide for respawning

func _on_respawn_timeout():
	# Respawn the health upgrade
	show()
	$CollisionShape2D.disabled = false
	print("Health upgrade respawned!")

func create_floating_animation():
	# Simple floating animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property($Sprite2D, "position:y", position.y - 5, 1.0)
	tween.tween_property($Sprite2D, "position:y", position.y, 1.0)
