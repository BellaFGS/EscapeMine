extends Node

func gerar_drop():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var roll = rng.randi_range(1, 100)

	if roll <= 5:
		return preload(res://scenes/items/item_chave.tscn")
	elif roll <= 35:
		return preload("res://scenes/items/item_forca.tscn")
	elif roll <= 70:
		return preload("res://scenes/items/item_vida.tscn")
	else:
		return null
