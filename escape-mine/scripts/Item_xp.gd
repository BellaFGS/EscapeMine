extends "res://scripts/Item.gd"

@export var valor: int = 1

func _on_body_entered(body):
	if body.is_in_group("player"):
		aplicar(body)
		
func aplicar(player):
	player.ganhar_xp(valor)
	queue_free()
