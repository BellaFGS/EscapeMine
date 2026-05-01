extends "res://scripts/Item.gd"
class_name DinamiteItem

func _ready():
	pass
	
func _on_body_entered(body):
	if body.name == "player":
		aplicar(body)

func aplicar(player):
	player.inventario.adicionar_item("dinamite", 1)
	queue_free()
