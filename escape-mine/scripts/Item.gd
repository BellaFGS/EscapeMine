extends Node2D
class_name Item

func _aplicar(player):
	pass

func clonar():
	return duplicate()

func _on_body_entered(body):
	print("colidiu com:", body)
	if body.has_method("pegar_item"):
		body.pegar_item(self)
