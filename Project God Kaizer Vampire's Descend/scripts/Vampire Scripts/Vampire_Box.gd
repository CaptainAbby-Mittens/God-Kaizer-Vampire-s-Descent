extends CharacterBody2D
@export var collider_offset: Vector2 = Vector2(0, -20)
@export var max_health: int = 50
@export var damage: int = 20
@export var move_speed: float = 80.0
@export var attack_range: float = 60.0
@export var detection_range: float = 400.0
@export var contact_damage_cooldown: float = 1.0
@onready var sprite: Sprite2D = $Sprite2D


var current_health: int
var player: Node2D
var is_player_detected: bool = false
var can_attack: bool = true
var attack_cooldown: float = 1.5
var can_deal_contact_damage: bool = true

enum State { IDLE, CHASING, ATTACKING, DEAD }
var current_state: State = State.IDLE


# Pre-generated collision polygons
var frame_polys: Array = []

func _ready():
	current_health = max_health
	collision_layer = 4
	collision_mask = 1 | 2
	add_to_group("enemy")



	if has_node("HitDetectionArea"):
		var hit_area = $HitDetectionArea
		hit_area.monitoring = true
		hit_area.monitorable = true
		hit_area.area_entered.connect(_on_hit_detection_area_entered)
		set_physics_process(true)

	if has_node("CollisionShape2D"):
		var shape = $CollisionShape2D
		if shape.get_parent() == self:
			var area = Area2D.new()
			area.name = "ContactDamageArea"
			add_child(area)
			var new_shape = CollisionShape2D.new()
			new_shape.shape = shape.shape
			area.add_child(new_shape)
			area.monitoring = true
			area.collision_layer = 0
			area.collision_mask = 1




	# Build collision polygons once




# ---------------- SIGNAL HANDLERS ---------------- #

func _on_hit_detection_area_entered(area):
	if area.is_in_group("weapon") and area.has_method("get_damage"):
		take_damage(area.get_damage())





# ---------------- STATE MACHINE ---------------- #

func _physics_process(delta):


	if has_node("HitDetectionArea"):
		for area in $HitDetectionArea.get_overlapping_areas():
			if area.is_in_group("weapon") and area.has_method("get_damage"):
				take_damage(area.get_damage())




# ---------------- ATTACK & DAMAGE ---------------- #



func take_damage(amount):
	current_health -= amount
	print("Vampire took ", amount, " damage! Health: ", current_health)
	if current_health <= 0:
		die()

func die():
	collision_layer = 0
	collision_mask = 0
	queue_free()

func _exit_tree():
	if has_node("HitDetectionArea"):
		var hit_area = $HitDetectionArea
		if hit_area.area_entered.is_connected(_on_hit_detection_area_entered):
			hit_area.area_entered.disconnect(_on_hit_detection_area_entered)
	remove_from_group("enemy")
	player = null
