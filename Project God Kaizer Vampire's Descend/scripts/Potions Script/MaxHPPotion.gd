# MaxHPPotion.gd
extends "res://scripts/Potions Script/BasePotion.gd"

func _ready():
	potion_type = "max_hp"
	super._ready()
	
	#if visual_node:
		#visual_node.modulate = Color(0, 1, 0)  # Green

func apply_effect(player):
	if player.has_method("increase_max_health"):
		player.increase_max_health(25)
		print("+25 Max HP granted!")
