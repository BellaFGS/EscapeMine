extends Node
var rng = RandomNumberGenerator.new()
var roll = rng.randi_range(1, 100)

func gerar_drop():
	rng.randomize()
	if roll <= 5:
		return preload("res://scenes/items/item_chave.tscn")
	elif roll <= 35:
		return preload("res://scenes/items/item_forca.tscn")
	elif roll <= 70:
		return preload("res://scenes/items/item_vida.tscn")
	else:
		return null
