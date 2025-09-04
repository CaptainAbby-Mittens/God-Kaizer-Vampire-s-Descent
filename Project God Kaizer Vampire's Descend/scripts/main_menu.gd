# MainMenu.gd
extends CanvasLayer

func _ready():
	get_tree().paused = false
	# Find your existing button - change "StartButton" to whatever you named your button
	var start_button = get_node_or_null("Panel/Button")
	
	if start_button:
		# Connect to your existing button
		start_button.pressed.connect(_on_start_button_pressed)
		start_button.grab_focus()  # Makes it highlight for gamepad/keyboard


func _on_start_button_pressed():
	print("Start button pressed! Beginning game...")
	
	# Hide the main menu
	hide()
	
	# Start the game - CHOOSE ONE OF THESE OPTIONS:
	
	# OPTION 1: If you use game.tscn as your main scene
	get_tree().change_scene_to_file("res://scenes/Area1/room_start.tscn")
	
