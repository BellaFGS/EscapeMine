extends Area2D


@export var spawner: Node2D

	
func _on_body_entered(body):

	if body.is_in_group("player"):

		print("Player entrou na área!")
		spawner.ativar()


func _on_body_exited(body):

	if body.is_in_group("player"):

		print("Player saiu da área!")

		spawner.desativar()
