extends "res://scripts/Item.gd"

@export var valor: int = 1

func aplicar(player):
	player.ganhar_xp(valor)
