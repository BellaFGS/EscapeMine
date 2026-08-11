class_name MeleeAttack
extends AttackStrategy


var dano: int = 20
var alcance: float = 70.0


func executar(boss, player) -> void:

	if not player:
		return

	# Para o boss durante o ataque
	boss.parar_movimento()

	# Toca a animação
	boss.tocar_animacao("attack")

	# Pequeno tempo antes do golpe acertar
	await boss.get_tree().create_timer(0.25).timeout

	if not is_instance_valid(player):
		return

	# Verifica se o jogador ainda está próximo
	if boss.global_position.distance_to(player.global_position) <= alcance:

		if player.has_method("receber_dano"):
			player.receber_dano(
				dano,
				boss.global_position,
				boss
			)

	await boss.get_tree().create_timer(0.35).timeout
