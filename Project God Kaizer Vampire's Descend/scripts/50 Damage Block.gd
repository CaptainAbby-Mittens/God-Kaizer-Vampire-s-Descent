# DamageBlock.gd
extends Area2D

@export var damage_amount: int = 50
@export var knockback_force: float = 300.0
@export var damage_cooldown: float = 0.5

# Color properties for visual feedback
@export var base_color: Color = Color.RED
@export var damage_color: Color = Color(1.0, 0.3, 0.3)  # Brighter red when damaging
@export var pulse_speed: float = 5.0

var players_in_area = []
var damage_timers = {}
var is_damaging: bool = false
var pulse_time: float = 0.0

@onready var color_rect = $ColorRect

func _ready():
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set up collision
	collision_layer = 1  # World layer
	collision_mask = 1   # Player layer
	
	# Initialize ColorRect appearance

func _process(delta):
	# Handle visual effects
	pulse_time += delta
	
	if color_rect:
		if is_damaging:
			# Pulsing effect when damaging
			var pulse = sin(pulse_time * pulse_speed) * 0.2 + 1.0
			color_rect.color = damage_color * Color(1, 1, 1, pulse * 0.8)


func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player entered damage block")
		players_in_area.append(body)
		is_damaging = true
		apply_damage(body)
		start_damage_timer(body)

func _on_body_exited(body):
	if body.is_in_group("player"):
		print("Player exited damage block")
		players_in_area.erase(body)
		
		# Stop timer if player leaves
		if body in damage_timers:
			damage_timers[body].stop()
			damage_timers.erase(body)
		
		# Update visual state
		if players_in_area.is_empty():
			is_damaging = false

func start_damage_timer(player):
	var timer = Timer.new()
	timer.wait_time = damage_cooldown
	timer.one_shot = false
	timer.timeout.connect(_on_damage_tick.bind(player))
	add_child(timer)
	timer.start()
	damage_timers[player] = timer

func _on_damage_tick(player):
	if player in players_in_area and is_instance_valid(player):
		# Flash effect on damage tick
		flash_damage_effect()
		apply_damage(player)
	else:
		if player in damage_timers:
			damage_timers[player].stop()
			damage_timers.erase(player)
		
		if players_in_area.is_empty():
			is_damaging = false

func flash_damage_effect():
	# Quick flash when damage is applied
	if color_rect:
		var tween = create_tween()
		tween.tween_property(color_rect, "color", damage_color * Color(1, 1, 1, 1.2), 0.1)
		tween.tween_property(color_rect, "color", damage_color * Color(1, 1, 1, 0.8), 0.1)

func apply_damage(player):
	if is_instance_valid(player) and player.has_method("take_damage"):
		player.take_damage(damage_amount)
		
		# Apply knockback away from the block
		var knockback_direction = (player.global_position - global_position).normalized()
		player.velocity = knockback_direction * knockback_force
		
		print("Applied ", damage_amount, " damage to player")

func _exit_tree():
	# Clean up timers
	for timer in damage_timers.values():
		if is_instance_valid(timer):
			timer.stop()
			timer.queue_free()
	damage_timers.clear()
