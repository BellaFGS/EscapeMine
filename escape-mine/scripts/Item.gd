extends Area2D

func aplicar(player):
	pass

func _on_body_entered(body):
	print("colidiu com:", body)
	if body.has_method("pegar_item"):
		body.pegar_item(self)
