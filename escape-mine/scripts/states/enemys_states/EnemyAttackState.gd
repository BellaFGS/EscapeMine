class_name EnemyAttackState
extends EnemyState

var tempo_ataque := 0.0


func entrar():
	tempo_ataque = 0.0

	if not is_instance_valid(inimigo):
		return

	inimigo.is_attack = true
	inimigo.velocity = Vector2.ZERO
	inimigo.move_and_slide()

	var nome_animacao = StringName(
		"attack_" + inimigo.ultima_direcao
	)

	if is_instance_valid(inimigo.anim):
		if inimigo.anim.has_animation(nome_animacao):
			inimigo.anim.play(nome_animacao)

	var player = obter_player()

	if not is_instance_valid(player):
		return

	var distancia = inimigo.global_position.distance_to(
		player.global_position
	)

	if distancia <= inimigo.alcance_ataque + 8.0:
		player.receber_dano(
			inimigo.forca,
			inimigo.global_position,
			inimigo
		)


func sair():
	if is_instance_valid(inimigo):
		inimigo.is_attack = false


func atualizar(delta: float) -> void:
	tempo_ataque += delta

	if not is_instance_valid(inimigo):
		return

	if inimigo.esta_morto or inimigo.vida <= 0:
		inimigo.state_machine.mudar_estado(&"morto")
		return

	if inimigo.tomando_dano:
		inimigo.state_machine.mudar_estado(&"ferido")
		return

	if tempo_ataque >= inimigo.intervalo_ataque:
		inimigo.state_machine.mudar_estado(&"perseguir")


func fisica(_delta: float) -> void:
	if not is_instance_valid(inimigo):
		return

	inimigo.velocity = Vector2.ZERO
	inimigo.move_and_slide()
