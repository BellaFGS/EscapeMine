class_name DashAttackStrategy
extends "res://scripts/boss/strategies/BossAttackStrategy.gd"

## Dash: o boss mira na posição do player, toca a animação "Dash" e
## avança rápido nessa direção com a hitBox ligada durante o trajeto,
## causando dano em quem estiver no caminho.

var velocidade_dash: float = 900.0
var tempo_preparo: float = 0.25   # "telegraph" antes de sair correndo
var duracao_dash: float = 0.35
var tempo_recuperacao: float = 0.3


func _init() -> void:
	nome = "Dash"
	alcance_min = 150.0
	alcance_max = 500.0
	cooldown = 4.0


func executar(boss) -> void:
	resetar_cooldown()
	boss.is_attack = true

	if not boss.player or not is_instance_valid(boss.player):
		boss.is_attack = false
		return

	var direcao = (boss.player.global_position - boss.global_position).normalized()

	if abs(direcao.x) > abs(direcao.y):
		boss.ultima_direcao = "right" if direcao.x > 0 else "left"
	else:
		boss.ultima_direcao = "down" if direcao.y > 0 else "up"

	boss.anim.play("Dash")

	# aviso visual antes do dash (dá pro player reagir)
	await boss.get_tree().create_timer(tempo_preparo).timeout
	if not is_instance_valid(boss) or boss.esta_morto:
		return

	var hitbox = boss.get_node("hitBox")
	hitbox.forca = boss.forca
	hitbox.dono = boss
	hitbox.set_deferred("monitoring", true)
	hitbox.get_node("Collision").set_deferred("disabled", false)

	var tempo_passado := 0.0
	while tempo_passado < duracao_dash:
		if not is_instance_valid(boss) or boss.esta_morto:
			return
		boss.velocity = direcao * velocidade_dash
		boss.move_and_slide()
		tempo_passado += boss.get_physics_process_delta_time()
		await boss.get_tree().physics_frame

	hitbox.set_deferred("monitoring", false)
	hitbox.get_node("Collision").set_deferred("disabled", true)
	boss.velocity = Vector2.ZERO

	await boss.get_tree().create_timer(tempo_recuperacao).timeout
	if not is_instance_valid(boss):
		return

	boss.is_attack = false
