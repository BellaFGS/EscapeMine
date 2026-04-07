extends "res://scripts/Item.gd"

func aplicar(player):
	GameManager.player_tem_chave = true
	print("Player pegou a chave")
