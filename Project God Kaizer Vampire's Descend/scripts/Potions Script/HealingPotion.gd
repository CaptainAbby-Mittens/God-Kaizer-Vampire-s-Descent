# HealingPotion.gd
extends "res://scripts/Potions Script/BasePotion.gd"

func _ready():
	potion_type = "healing"
	super._ready()  # Call parent's _ready() first
	
	# Now use visual_node instead of sprite
	if visual_node:
		visual_node.modulate = Color(0, 1, 1)  # Cyan

func apply_effect(player):
	if player.has_method("heal"):
		player.heal(50)
		print("+50 HP healed!")
		
