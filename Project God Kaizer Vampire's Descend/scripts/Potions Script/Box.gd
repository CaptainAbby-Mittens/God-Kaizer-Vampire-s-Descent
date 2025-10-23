extends StaticBody2D

@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite2D

func _ready():
	# Connect area entered for sword hits
	var area = $Area2D  # Add a child Area2D for sword detection
	area.area_entered.connect(_on_sword_hit)
	
	# Body entered will automatically work for character collision

func _on_sword_hit(area: Area2D):
	if area.get_collision_layer_value(2):
		print("Hit by sword!")
		sprite.visible = false
		collision_shape.set_deferred("disabled", true)
