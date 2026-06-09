extends Node

var rng = RandomNumberGenerator.new()

const XP_SCENE = preload("res://scenes/items/item_xp.tscn")
const CHAVE_SCENE = preload("res://scenes/items/item_chave.tscn")
const ESCUDO_SCENE = preload("res://scenes/items/item_escudo.tscn")

func gerar_drops(dificuldade: int) -> Array:
	rng.randomize()

	var drops = []

	# ⭐ XP sempre
	var xp = XP_SCENE.instantiate()
	xp.valor = rng.randi_range(1, 5)
	drops.append(xp)

	# 🔑 Chance da chave
	var chance_chave = clamp(1 + dificuldade * 2, 1, 25)

	if rng.randi_range(1, 100) <= chance_chave:
		var chave = CHAVE_SCENE.instantiate()
		drops.append(chave)

	# 🛡️ Chance do escudo
	var chance_escudo = clamp(5 + dificuldade, 5, 15)

	if rng.randi_range(1, 100) <= chance_escudo:
		var escudo = ESCUDO_SCENE.instantiate()
		drops.append(escudo)

	return drops
