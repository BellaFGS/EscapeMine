class_name AreaAttack
extends AttackStrategy


var dano: int = 30
var raio: float = 120.0


func executar(boss, player) -> void:

	boss.parar_movimento()

	boss.tocar_animacao("area_attack")

	# Tempo para o jogador perceber o ataque
	await boss.get_tree().create_timer(0.6).timeout

	if not is_instance_valid(player):
		return

	var distancia = boss.global_position.distance_to(
		player.global_position
	)

	if distancia <= raio:

		if player.has_method("receber_dano"):
			player.receber_dano(
				dano,
				boss.global_position,
				boss
			)

	await boss.get_tree().create_timer(0.4).timeout
