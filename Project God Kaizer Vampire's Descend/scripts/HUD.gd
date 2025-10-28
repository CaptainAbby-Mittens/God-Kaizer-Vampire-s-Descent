extends CanvasLayer

@onready var label_score = $Control/VBoxContainer/Score
@onready var label_shield = $Control/VBoxContainer/Shield
@onready var label_crit = $Control/VBoxContainer/Crit
@onready var label_damage = $Control/VBoxContainer/Damage
@onready var label_abilities = $Control/VBoxContainer/Abilties

func _ready():
	$Control/VBoxContainer.position = Vector2(550, 0)  # top-right-ish
	#$Shield.position = Vector2(500, 60)
	#$Damage.position = Vector2(500, 90)
	#$Crit.position = Vector2(500, 120)
	#$Abilties.position = Vector2(500, 150)
	update_display()
	
	# Update automatically when GameManager changes
	if get_node_or_null("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		gm.connect("playtime_updated", Callable(self, "_on_playtime_update"))  # optional
		# Call update each frame or use custom signals (preferred)
		set_process(true)

func _process(_delta):
	update_display()

func update_display():
	var gm = get_node_or_null("/root/GameManager")
	if not gm:
		return

	label_score.text = "Score: " + str(gm.score)
	label_shield.text = "Shield: " + str(gm.shield)
	label_crit.text = "Crit: " + str(gm.crit)
	label_damage.text = "Damage: " + str(gm.player_damage)

	var abilities = []

	if gm.vampirism: abilities.append("\nVampirism")
	if gm.autoheal: abilities.append("\nAuto Heal")
	if gm.fireball: abilities.append("\nFireball")
	if gm.supermode: abilities.append("\nSuper Mode")

	label_abilities.text = "Abilities: " + (", ".join(abilities) if abilities.size() > 0 else "\nNone")

func _on_playtime_update(_t):
	update_display()
