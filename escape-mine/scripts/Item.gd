extends Area2D

func aplicar(player):
	pass

func _on_body_entered(body):
	if body.has_method("pegar_item"):
		body.pegar_item(self)
