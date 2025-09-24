# DamagePotion.gd
extends "res://scripts/Potions Script/BasePotion.gd"

func _ready():
	potion_type = "damage"
	super._ready()
	
	if visual_node:
		visual_node.modulate = Color(1, 0, 0)  # Red

func apply_effect(player):
	if player.has_method("take_damage"):
		player.take_damage(40)
		print("Took 40 damage from potion!")
