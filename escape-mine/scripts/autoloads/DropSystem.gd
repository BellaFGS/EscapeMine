extends Node

var rng = RandomNumberGenerator.new()

const XP_SCENE = preload("res://scenes/items/item_xp.tscn")
const CHAVE_SCENE = preload("res://scenes/items/item_chave.tscn")
const ESCUDO_SCENE = preload("res://scenes/items/item_escudo.tscn")


# ============================================================
# DROP NORMAL
# ============================================================

func gerar_drops() -> Array:

	rng.randomize()

	var drops = []

	# ⭐ XP
	var xp = XP_SCENE.instantiate()
	xp.valor = rng.randi_range(1, 5)
	drops.append(xp)

	# 🔑 CHAVE
	var chance_chave = 5

	if rng.randi_range(1, 100) <= chance_chave:

		var chave = CHAVE_SCENE.instantiate()
		drops.append(chave)

	# 🛡️ ESCUDO
	var chance_escudo = 10

	if rng.randi_range(1, 100) <= chance_escudo:

		var escudo = ESCUDO_SCENE.instantiate()
		drops.append(escudo)

	return drops


# ============================================================
# DROP DO MINIOM
# ============================================================

func gerar_drops_miniom() -> Array:

	rng.randomize()

	var drops = []

	# ⭐ XP sempre
	var xp = XP_SCENE.instantiate()
	xp.valor = rng.randi_range(1, 5)
	drops.append(xp)

	# 🛡️ Escudo
	var chance_escudo = 10

	if rng.randi_range(1, 100) <= chance_escudo:

		var escudo = ESCUDO_SCENE.instantiate()
		drops.append(escudo)

	return drops
