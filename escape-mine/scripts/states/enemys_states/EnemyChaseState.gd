class_name EnemyChaseState
extends EnemyState


func entrar():
	pass


func sair():
	pass


func fisica(_delta: float) -> void:
	if not is_instance_valid(inimigo):
		return

	if inimigo.esta_morto or inimigo.vida <= 0:
		inimigo.state_machine.mudar_estado(&"morto")
		return

	if inimigo.tomando_dano:
		inimigo.state_machine.mudar_estado(&"ferido")
		return

	var player = obter_player()

	if not is_instance_valid(player):
		inimigo.mover(Vector2.ZERO)
		return

	var distancia = inimigo.global_position.distance_to(
		player.global_position
	)

	if distancia <= inimigo.alcance_ataque:
		inimigo.state_machine.mudar_estado(&"atacar")
		return

	var direcao = (
		player.global_position
		- inimigo.global_position
	).normalized()

	inimigo.mover(direcao)
