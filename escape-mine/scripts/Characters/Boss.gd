extends "res://scripts/Character.gd"


# ============================================================
# BOSS
# ============================================================

var player

# Controle de combate
var atacando: bool = false
var pode_atacar: bool = true

# Distâncias
var distancia_ataque: float = 90.0
var distancia_area: float = 180.0
var distancia_dash: float = 250.0

# Cooldown geral
var cooldown_ataque: float = 1.2

# ============================================================
# STRATEGY PATTERN
# ============================================================

class BossAttackStrategy extends RefCounted:

	func executar(boss, alvo) -> void:
		pass

	func pode_executar(boss, alvo) -> bool:
		return true

func _physics_process(delta):

	if esta_morto:
		return

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return

	atualizar_direcao()

	if atacando:
		return

	var distancia = global_position.distance_to(
		player.global_position
	)

	if distancia > distancia_ataque:

		var direcao = (
			player.global_position -
			global_position
		).normalized()

		mover(direcao)
		tocar_animacao("walk")

	else:

		parar_movimento()

		if pode_atacar:
			escolher_ataque()


func atualizar_direcao():

	if not player:
		return

	if player.global_position.x < global_position.x:
		$Animacao.flip_h = true
	else:
		$Animacao.flip_h = false

# ============================================================
# ESCOLHER ATAQUE
# ============================================================

func escolher_ataque():

	if atacando:
		return

	if not pode_atacar:
		return

	if not is_instance_valid(player):
		return

	atacando = true
	pode_atacar = false

	var estrategia = selecionar_strategy()

	if estrategia:

		await estrategia.executar(
			self,
			player
		)

	atacando = false

	# Volta para idle
	tocar_animacao("default")

	# Cooldown
	await get_tree().create_timer(
		cooldown_ataque
	).timeout

	pode_atacar = true


# ============================================================
# STRATEGY SELECTION
# ============================================================

func selecionar_strategy() -> AttackStrategy:

	var distancia = global_position.distance_to(
		player.global_position
	)

	if distancia <= distancia_ataque:

		var ataques_proximos = [
			MeleeAttack.new(),
			MeleeAttack.new(),
			DashAttack.new()
		]

		return ataques_proximos.pick_random()


	if distancia <= distancia_area:

		var ataques_medios = [
			DashAttack.new()
		]

		return ataques_medios.pick_random()


	return DashAttack.new()
func parar_movimento():

	velocity = Vector2.ZERO

func tocar_animacao(nome: String):

	if not has_node("Animacao"):
		return

	var sprite = $Animacoa

	if sprite.sprite_frames == null:
		return

	if sprite.sprite_frames.has_animation(nome):

		sprite.play(nome)


# ============================================================
# MORTE
# ============================================================

func morrer():

	if esta_morto:
		return

	esta_morto = true

	atacando = false
	pode_atacar = false

	velocity = Vector2.ZERO
	tocar_animacao("default")
	call_deferred("_morrer_safe")


func _morrer_safe():

	# --------------------------------------------------------
	# DROP
	# --------------------------------------------------------

	var drops = DropSystem.gerar_drops(
		GameManager.dificuldade
	)

	for item in drops:

		get_tree().current_scene.add_child(item)

		item.global_position = global_position


	# --------------------------------------------------------
	# XP
	# --------------------------------------------------------

	if ultimo_atacante and ultimo_atacante.is_in_group("player"):

		UpgradeSystem.ganhar_xp(
			randi_range(1, 5)
		)


	# --------------------------------------------------------
	# DESATIVAR HURTBOX
	# --------------------------------------------------------

	if has_node("hurtBox"):

		$hurtBox.set_deferred(
			"monitoring",
			false
		)


	queue_free()


# ============================================================
# RECEBER DANO
# ============================================================

func _on_hurt_box_area_entered(area: Area2D) -> void:

	if esta_morto:
		return

	# Ataques que possuem força e dono
	if "forca" in area and "dono" in area:

		receber_dano(
			area.forca,
			area.dono.global_position,
			area.dono
		)

		return


	# Armadilhas
	if area.is_in_group("trap"):

		receber_dano(
			50,
			area.global_position,
			null
		)
