# MysteryPotion.gd
extends "res://scripts/Potions Script/BasePotion.gd"

func _ready():
	potion_type = "mystery"
	super._ready()
	
	if visual_node:
		visual_node.modulate = Color(0.5, 0, 0.5)  # Purple

func apply_effect(player):
	var effects = ["max_hp", "heal", "damage"]
	var chosen_effect = effects[randi() % effects.size()]
	
	match chosen_effect:
		"max_hp":
			if player.has_method("increase_max_health"):
				player.increase_max_health(25)
				print("Mystery: +25 Max HP!")
		"heal":
			if player.has_method("heal"):
				player.heal(50)
				print("Mystery: +50 HP healed!")
		"damage":
			if player.has_method("take_damage"):
				player.take_damage(30)
				print("Mystery: -30 HP damage!")
