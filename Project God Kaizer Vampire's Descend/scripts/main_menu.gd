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
	print("Start button pressed")
	
	# Reset playtime timer if GameManager exists
	if has_node("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		if gm.has_method("restart_playtime_timer"):
			gm.restart_playtime_timer()
		if gm.has_method("start_playtime_timer"):
			gm.start_playtime_timer()
	
	# Start the game
	start_game()
	
	
func start_game():
	# Your existing game start logic here
	# Example:
	
	#   Start the game - CHOOSE ONE OF THESE OPTIONS:
	
	# OPTION 1: If you use game.tscn as your main scene
	get_tree().change_scene_to_file("res://scenes/Area1/room_start.tscn")
	
