class_name DashAttack
extends AttackStrategy


var dano: int = 35
var velocidade: float = 500.0
var duracao: float = 0.35


func executar(boss, player) -> void:

	if not player:
		return

	boss.parar_movimento()

	boss.tocar_animacao("dash")

	var direcao = (
		player.global_position -
		boss.global_position
	).normalized()

	var tempo = 0.0

	while tempo < duracao:

		if not is_instance_valid(boss):
			return

		boss.velocity = direcao * velocidade
		boss.move_and_slide()

		if is_instance_valid(player):

			if boss.global_position.distance_to(
				player.global_position
			) < 45:

				if player.has_method("receber_dano"):
					player.receber_dano(
						dano,
						boss.global_position,
						boss
					)

				break

		await boss.get_tree().process_frame

		tempo += boss.get_process_delta_time()

	boss.velocity = Vector2.ZERO
