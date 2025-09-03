# UI_HealthValue.gd
extends Control

@onready var progress_bar = $ProgressBar
@onready var label = $Label

func _ready():
	# Make it a top-level node
	print("Health bar scene loaded!")
	top_level = true
	move_child(label, get_child_count() - 1)
	
	# Configure progress bar - SETUP ONLY, NO VALUES
	progress_bar.min_value = 0
	progress_bar.size = Vector2(200, 20)
	
	# Apply RED style to progress bar
	style_progress_bar_red()
	
	# Configure label - SETUP ONLY, NO VALUES
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = "HP: ..."  # ← Temporary placeholder
	
	# Apply BLACK text color
	style_label_black()
	
	# Set screen position
	global_position = Vector2(20, 20)
	
	# Center label on progress bar
	center_label()
	
	# Connect to player for ACTUAL values
	await get_tree().create_timer(0.1).timeout
	connect_to_player()

func style_progress_bar_red():
	# Create a RED style for the progress bar
	var style_fg = StyleBoxFlat.new()  # Foreground (fill)
	style_fg.bg_color = Color.RED
	style_fg.border_color = Color.DARK_RED
	style_fg.border_width_left = 1
	style_fg.border_width_right = 1
	style_fg.border_width_top = 1
	style_fg.border_width_bottom = 1
	
	var style_bg = StyleBoxFlat.new()  # Background
	style_bg.bg_color = Color(0.3, 0.3, 0.3)  # Dark gray background
	style_bg.border_color = Color.BLACK
	style_bg.border_width_left = 1
	style_bg.border_width_right = 1
	style_bg.border_width_top = 1
	style_bg.border_width_bottom = 1
	
	# Apply the styles
	progress_bar.add_theme_stylebox_override("fill", style_fg)
	progress_bar.add_theme_stylebox_override("background", style_bg)

func style_label_black():
	# Set label text color to BLACK
	label.add_theme_color_override("font_color", Color.BLACK)
	
	# Optional: Add text outline for better visibility
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_color_override("font_outline_color", Color.WHITE)

func update_health(current: int, max: int):
	var current_int = (current)
	var max_int = (max)
	progress_bar.max_value = max  # ← Use the actual max value from player!
	progress_bar.value = current
	label.text = "HP: %d/%d" % [current, max]
	center_label()

func center_label():
	await get_tree().process_frame
	var center_x = (progress_bar.size.x - label.size.x) / 2
	var center_y = (progress_bar.size.y - label.size.y) / 2
	label.position = Vector2(center_x, center_y)
func connect_to_player():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("health_updated"):
		player.health_updated.connect(update_health)
		update_health(player.current_health, player.max_health)
		print("Health bar connected to player!")
	else:
		# Try again every 0.5 seconds until player is found
		await get_tree().create_timer(0.5).timeout
		connect_to_player()
