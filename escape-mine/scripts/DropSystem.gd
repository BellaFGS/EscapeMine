extends Node

var rng = RandomNumberGenerator.new()

const XP_SCENE = preload("res://scenes/items/item_xp.tscn")
const CHAVE_SCENE = preload("res://scenes/items/item_chave.tscn")

func gerar_drops(dificuldade: int) -> Array:
	rng.randomize()
	
	var drops = []
	
	# ⭐ XP sempre
	var xp = XP_SCENE.instantiate()
	xp.valor = rng.randi_range(1, 5)
	drops.append(xp)
	
	# 🔑 chance da chave
	var chance_chave = 2 + (dificuldade * 3)
	var roll = rng.randi_range(1, 100)
	
	if roll <= chance_chave:
		var chave = CHAVE_SCENE.instantiate()
		drops.append(chave)
	
	return drops
