extends "res://scripts/Item.gd"
class_name DinamiteItem

func _ready():
	pass
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		aplicar(body)

func aplicar(player):
	player.adicionar_item("dinamite")
	queue_free()
