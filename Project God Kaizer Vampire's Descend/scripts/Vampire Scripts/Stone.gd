extends Area2D

@export var speed: float = 250.0
@export var damage: int = 30
@export var knockback_force: float = 300.0
@export var lifetime: float = 3.0

var direction: int = 1
var is_queued_for_free: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	collision_shape.disabled = false
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	if is_queued_for_free:
		return
	position.x += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if is_queued_for_free or body == null:
		return
	
	# Only handle player hits here
	if body.is_in_group("player"):
		print("Player body hit!")
		apply_effect(body)
		destroy_immediately()

func _on_area_entered(area: Area2D) -> void:
	if is_queued_for_free or area == null:
		return
	
	print("Area hit: ", area.name)
	print("Area groups: ", area.get_groups())
	
	# This is where weapon detection happens!
	if area.is_in_group("weapon") :
		print("Weapon area hit - destroying rock immediately!")
		destroy_immediately()

func destroy_immediately() -> void:
	if is_queued_for_free:
		return
	
	is_queued_for_free = true
	print("Rock destroyed immediately!")
	
	# Stop all movement and processing
	set_physics_process(false)
	
	# Disable collision immediately
	collision_shape.set_deferred("disabled", true)
	
	# Hide visually
	if sprite:
		sprite.visible = false
	
	# Free immediately
	call_deferred("queue_free")

func apply_effect(player: Node) -> void:
	if player.has_method("take_damage"):
		player.take_damage(damage)
	apply_knockback(player)

func apply_knockback(player: Node) -> void:
	if player == null:
		return
	
	var knockback_direction = Vector2(direction, -0.5).normalized()
	var knockback_vector = knockback_direction * knockback_force
	
	if player.has_method("apply_knockback"):
		player.apply_knockback(knockback_vector)
	elif player.has_method("apply_central_impulse"):
		player.apply_central_impulse(knockback_vector)
	elif player is CharacterBody2D:
		player.velocity += knockback_vector
