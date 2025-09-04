# EndScreen.gd
extends CanvasLayer

@onready var timer = $Timer
@onready var countdown_label = $CountdownLabel  # Add this label to your scene

func _ready():
	# Start the countdown
	timer.start()
	
	# Start updating countdown text
	update_countdown()

func _process(delta):
	# Update countdown text every frame
	update_countdown()

func update_countdown():
	var time_left = timer.time_left
	countdown_label.text = "Returning to main menu in %.1f seconds..." % time_left

func _on_timer_timeout():
	# Timer finished, return to main menu
	print("Returning to main menu...")
	get_tree().change_scene_to_file("res://scenes/Area1/MainMenu.tscn")
	
	# Optional: Remove the end screen
	queue_free()
