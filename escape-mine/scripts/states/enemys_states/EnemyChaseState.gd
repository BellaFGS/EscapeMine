class_name EnemyChaseState
extends EnemyState


func entrar():
	print(inimigo.name, " entrou em PERSEGUIR")


func sair():
	pass


func fisica(_delta):

	var player = obter_player()

	if not is_instance_valid(player):
		return

	var direcao = (
		player.global_position
		- inimigo.global_position
	).normalized()

	inimigo.mover(direcao)
