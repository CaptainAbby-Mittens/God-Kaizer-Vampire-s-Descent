# EndScreen.gd
extends CanvasLayer

@onready var timer = $Timer
@onready var countdown_label = $CountdownLabel
@onready var playtime_label = $PlaytimeLabel
@onready var detailed_time_label = $DetailedTimeLabel
@onready var score_label = $Score  # This should reference a Label node, not a variable

@export var show_milliseconds: bool = false

func display_playtime_stats():
	if not has_node("/root/GameManager"):
		print("GameManager not found!")
		return
	
	var game_manager = get_node("/root/GameManager")
	var total_seconds = game_manager.get_current_playtime()
	
	# Update main label
	if playtime_label:
		playtime_label.text = "Your Time: " + format_time(total_seconds, show_milliseconds)
	
	# Optional: Detailed breakdown
	if detailed_time_label:
		var hours = int(total_seconds) / 3600
		var minutes = (int(total_seconds) % 3600) / 60
		var seconds = int(total_seconds) % 60
		detailed_time_label.text = "Time Played: %d hours, %d minutes, %d seconds" % [hours, minutes, seconds]
		
	# FIXED: Score display
	if score_label:
		# Check if score exists in GameManager and set appropriate text
		if game_manager.has_method("get_score"):
			score_label.text = "Score: " + str(game_manager.get_score())
		elif "score" in game_manager:
			score_label.text = "Score: " + str(game_manager.score)
		else:
			score_label.text = "Score: 0"  # Default if no score system

func format_time(seconds: float, show_ms: bool = false) -> String:
	var minutes = int(seconds) / 60
	var seconds_remaining = int(seconds) % 60
	
	if show_ms:
		var milliseconds = int((seconds - int(seconds)) * 100)
		return "%02d:%02d.%02d" % [minutes, seconds_remaining, milliseconds]
	else:
		return "%02d:%02d" % [minutes, seconds_remaining]

# Optional: Add animation to make the time display more dramatic
func animate_time_reveal():
	if playtime_label:
		var original_text = playtime_label.text
		playtime_label.text = "00:00"
		
		# Count up to the actual time
		var tween = create_tween()
		tween.tween_method(animate_countup, 0.0, get_playtime_value(), 2.0).set_ease(Tween.EASE_OUT)

func animate_countup(value: float):
	if playtime_label:
		playtime_label.text = format_time(value)

func get_playtime_value() -> float:
	if has_node("/root/GameManager"):
		return get_node("/root/GameManager").get_current_playtime()
	return 0.0

func _ready():
	# Start the countdown
	timer.start()
	await get_tree().process_frame
	display_playtime()
	display_playtime_stats()  # Call this to display score too
	update_countdown()

func display_playtime():
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		var total_playtime = game_manager.get_current_playtime()
		var formatted_time = format_time(total_playtime)
		
		# Update your label
		if playtime_label:
			playtime_label.text = "Time: " + formatted_time
		else:
			print("Playtime label not found!")
		
		print("Final playtime: ", formatted_time)
	else:
		print("GameManager not found!")

# Optional: Fancy display with hours
func format_time_detailed(seconds: float) -> String:
	var hours = int(seconds) / 3600
	var minutes = (int(seconds) % 3600) / 60
	var seconds_remaining = int(seconds) % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds_remaining]

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
