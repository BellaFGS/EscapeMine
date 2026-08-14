class_name MeleeAttackStrategy
extends "res://scripts/boss/strategies/BossAttackStrategy.gd"

## Ataque corpo a corpo: o boss vira pro player, toca a animação "Attack"
## e liga a hitBox numa janela curta de tempo (igual ao atacar() do Character,
## mas orientado pela posição do player em vez do mouse).

func _init() -> void:
	nome = "Ataque Melee"
	alcance_min = 0.0
	alcance_max = 140.0
	cooldown = 1.8


func executar(boss) -> void:
	resetar_cooldown()
	boss.is_attack = true
	boss.velocity = Vector2.ZERO

	var hitbox = boss.get_node("hitBox")
	hitbox.forca = boss.forca
	hitbox.dono = boss

	if boss.player:
		var direcao = (boss.player.global_position - boss.global_position).normalized()
		if abs(direcao.x) > abs(direcao.y):
			boss.ultima_direcao = "right" if direcao.x > 0 else "left"
		else:
			boss.ultima_direcao = "down" if direcao.y > 0 else "up"

	boss.anim.play("Attack")

	# tempo até o "impacto" da animação
	await boss.get_tree().create_timer(0.35).timeout
	if not is_instance_valid(boss) or boss.esta_morto:
		return

	hitbox.set_deferred("monitoring", true)
	hitbox.get_node("Collision").set_deferred("disabled", false)

	# duração da janela de dano
	await boss.get_tree().create_timer(0.25).timeout
	if not is_instance_valid(boss):
		return

	hitbox.set_deferred("monitoring", false)
	hitbox.get_node("Collision").set_deferred("disabled", true)

	# tempo de recuperação antes de poder agir de novo
	await boss.get_tree().create_timer(0.2).timeout
	if not is_instance_valid(boss):
		return

	boss.is_attack = false
