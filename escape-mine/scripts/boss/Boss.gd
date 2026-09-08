extends "res://scripts/Character.gd"


# ============================================================
# STRATEGY PATTERN
# ============================================================

@export var minion_scene: PackedScene

## Distância a partir da qual o boss persegue o player
@export var alcance_perseguicao: float = 550.0

## Distância confortável que o boss tenta manter
@export var distancia_ideal: float = 130.0

## Recompensa especial por derrotar o chefe
@export var bonus_pontos: int = 1000


var player
var estrategias: Array = []
var estrategia_ativa = null

var _tempo_travado_em_ataque: float = 0.0

const TEMPO_MAX_ATAQUE: float = 3.0


func _ready() -> void:

	super._ready()

	# ========================================================
	# ANIMAÇÃO
	# ========================================================

	anim = get_node_or_null("Animacao")


	# ========================================================
	# VALORES DE SEGURANÇA
	# ========================================================

	if speed == null:
		speed = 120

	if tempo_invencibilidade == null:
		tempo_invencibilidade = 0.5


	# ========================================================
	# PLAYER
	# ========================================================

	player = get_tree().get_first_node_in_group("player")


	# ========================================================
	# ESTRATÉGIAS
	# ========================================================

	estrategias = [
		MeleeAttackStrategy.new(),
		DashAttackStrategy.new(),
		SummonMinionsStrategy.new(),
	]


func _physics_process(delta: float) -> void:

	if esta_morto:
		return


	# ========================================================
	# PROCURAR PLAYER
	# ========================================================

	if player == null or not is_instance_valid(player):

		player = get_tree().get_first_node_in_group("player")

		return


	# ========================================================
	# DIREÇÃO
	# ========================================================

	virar_para_player()


	# ========================================================
	# COOLDOWNS
	# ========================================================

	for estrategia in estrategias:

		estrategia.atualizar_cooldown(delta)


	# ========================================================
	# MOVIMENTO
	# ========================================================

	if player:

		var direcao = (
			player.global_position
			- global_position
		).normalized()

		mover(direcao)


	# ========================================================
	# ATAQUE
	# ========================================================

	if is_attack or estrategia_ativa != null:

		_tempo_travado_em_ataque += delta


		if _tempo_travado_em_ataque > TEMPO_MAX_ATAQUE:

			push_warning(
				"Boss: destravando is_attack " +
				"(provável erro numa estratégia)."
			)

			is_attack = false
			estrategia_ativa = null
			_tempo_travado_em_ataque = 0.0


		return


	_tempo_travado_em_ataque = 0.0


	var distancia = global_position.distance_to(
		player.global_position
	)


	var escolhida = _escolher_estrategia(distancia)


	if escolhida:

		_executar_estrategia(escolhida)

		return


# ============================================================
# ESCOLHER ESTRATÉGIA
# ============================================================

func _escolher_estrategia(distancia: float):

	var candidatas = []


	for estrategia in estrategias:

		if estrategia.pode_executar(
			self,
			distancia
		):

			candidatas.append(estrategia)


	if candidatas.is_empty():

		return null


	return candidatas[
		randi() % candidatas.size()
	]


# ============================================================
# EXECUTAR ESTRATÉGIA
# ============================================================

func _executar_estrategia(estrategia) -> void:

	estrategia_ativa = estrategia

	await estrategia.executar(self)

	estrategia_ativa = null


# ============================================================
# ANIMAÇÃO
# ============================================================

func atualizar_animacao(_direcao) -> void:

	if anim == null or is_attack:

		return


	anim.play("default")


# ============================================================
# DIREÇÃO DO BOSS
# ============================================================

func virar_para_player() -> void:

	if anim == null or player == null:

		return


	var diferenca_x = (
		player.global_position.x
		- global_position.x
	)


	if diferenca_x > 1.0:

		anim.flip_h = false
		ultima_direcao = "right"


	elif diferenca_x < -1.0:

		anim.flip_h = true
		ultima_direcao = "left"


# ============================================================
# MORTE
# ============================================================

func morrer() -> void:

	if esta_morto:

		return


	esta_morto = true

	call_deferred("_morrer_impl")


func _morrer_impl() -> void:

	# ========================================================
	# DESATIVAR HURT BOX
	# ========================================================

	var hurt_box = get_node_or_null("hurtBox")

	if hurt_box:

		hurt_box.set_deferred(
			"monitoring",
			false
		)

		hurt_box.set_deferred(
			"monitorable",
			false
		)


	# ========================================================
	# DESATIVAR COLISÃO FÍSICA
	# ========================================================

	var collision = get_node_or_null("Collision")

	if collision:

		collision.set_deferred(
			"disabled",
			true
		)


	# ========================================================
	# ANIMAÇÃO DE MORTE
	# ========================================================

	if anim:

		anim.play("Death")


	# ========================================================
	# ESPERAR ANIMAÇÃO
	# ========================================================

	await get_tree().create_timer(
		1.2
	).timeout


	# ========================================================
	# DROP DO BOSS
	# ========================================================

	var drops = DropSystem.gerar_drop_boss()


	for item in drops:

		get_tree().current_scene.add_child(item)

		item.global_position = global_position


	# ========================================================
	# BONUS
	# ========================================================

	ScoreManager.adicionar_bonus_boss(
		bonus_pontos
	)


	# ========================================================
	# NÃO FINALIZA A PARTIDA AQUI
	# ========================================================

	queue_free()


# ============================================================
# DANO
# ============================================================

func _on_hurt_box_area_entered(area: Area2D) -> void:

	if "forca" in area and "dono" in area:

		receber_dano(
			area.forca,
			area.dono.global_position,
			area.dono
		)
