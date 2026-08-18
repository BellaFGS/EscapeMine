class_name MeleeAttackStrategy
extends "res://scripts/boss/strategies/BossAttackStrategy.gd"


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
	var hitbox2 = boss.get_node("hitBox2")

	# Configura as duas HitBoxes
	hitbox.forca = boss.forca
	hitbox.dono = boss

	hitbox2.forca = boss.forca
	hitbox2.dono = boss

	# Garante que ambas começam desligadas
	hitbox.set_deferred("monitoring", false)
	hitbox2.set_deferred("monitoring", false)

	hitbox.get_node("Collision").set_deferred("disabled", true)
	hitbox2.get_node("Collision").set_deferred("disabled", true)

	# Guarda a direção no momento em que o ataque começou.
	# Isso é importante para o boss não trocar de HitBox
	# no meio da animação.
	var direcao_ataque = boss.ultima_direcao

	# Animação
	boss.anim.play("Attack")

	# Espera até o impacto
	await boss.get_tree().create_timer(0.35).timeout

	if not is_instance_valid(boss) or boss.esta_morto:
		return

	# ========================================================
	# ATIVA A HITBOX
	# ========================================================

	var hitbox_ativa

	if direcao_ataque == "right":
		hitbox_ativa = hitbox
	else:
		hitbox_ativa = hitbox2

	hitbox_ativa.set_deferred("monitoring", true)
	hitbox_ativa.get_node("Collision").set_deferred(
		"disabled",
		false
	)

	# ========================================================
	# JANELA DE DANO
	# ========================================================

	await boss.get_tree().create_timer(0.25).timeout

	if not is_instance_valid(boss):
		return

	# Desativa a HitBox
	hitbox_ativa.set_deferred("monitoring", false)
	hitbox_ativa.get_node("Collision").set_deferred(
		"disabled",
		true
	)

	# ========================================================
	# RECUPERAÇÃO
	# ========================================================

	await boss.get_tree().create_timer(0.2).timeout

	if not is_instance_valid(boss):
		return

	boss.is_attack = false
