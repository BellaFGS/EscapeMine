extends "res://scripts/Character.gd"

# --- Strategy pattern ---
# MeleeAttackStrategy, DashAttackStrategy e SummonMinionsStrategy
# possuem class_name e ficam disponíveis globalmente.

@export var minion_scene: PackedScene

## Distância a partir da qual o boss persegue o player
@export var alcance_perseguicao: float = 550.0

## Distância confortável que o boss tenta manter
@export var distancia_ideal: float = 130.0

var player
var estrategias: Array = []
var estrategia_ativa = null

var _tempo_travado_em_ataque: float = 0.0
const TEMPO_MAX_ATAQUE: float = 3.0


func _ready() -> void:
	super._ready()

	# Animação do Boss
	anim = get_node_or_null("Animacao")

	# Valores padrão de segurança
	if speed == null:
		speed = 120

	if tempo_invencibilidade == null:
		tempo_invencibilidade = 0.5

	player = get_tree().get_first_node_in_group("player")

	estrategias = [
		MeleeAttackStrategy.new(),
		DashAttackStrategy.new(),
		SummonMinionsStrategy.new(),
	]


func _physics_process(delta: float) -> void:
	if esta_morto:
		return

	# Procurar player novamente caso ele não exista
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return

	# Atualiza direção horizontal do boss
	virar_para_player()

	# Atualiza cooldowns
	for estrategia in estrategias:
		estrategia.atualizar_cooldown(delta)

	# Movimento em direção ao player
	if player:
		var direcao = (
			player.global_position - global_position
		).normalized()

		mover(direcao)

	# Já está atacando
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

	var distancia = global_position.distance_to(player.global_position)

	var escolhida = _escolher_estrategia(distancia)

	if escolhida:
		_executar_estrategia(escolhida)
		return


## Escolhe uma estratégia disponível para a distância atual.
func _escolher_estrategia(distancia: float):
	var candidatas = []

	for estrategia in estrategias:
		if estrategia.pode_executar(self, distancia):
			candidatas.append(estrategia)

	if candidatas.is_empty():
		return null

	return candidatas[randi() % candidatas.size()]


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

# DIREÇÃO DO BOSS

func virar_para_player() -> void:
	if anim == null or player == null:
		return

	var diferenca_x = player.global_position.x - global_position.x

	# Player está à direita
	if diferenca_x > 1.0:
		anim.flip_h = false
		ultima_direcao = "right"

	# Player está à esquerda
	elif diferenca_x < -1.0:
		anim.flip_h = true
		ultima_direcao = "left"

# MORTE

func morrer() -> void:
	if esta_morto:
		return

	esta_morto = true
	call_deferred("_morrer_impl")


func _morrer_impl() -> void:
	# Desativa as colisões imediatamente ao morrer
	var hurt_box = get_node_or_null("hurtBox")
	if hurt_box:
		hurt_box.set_deferred("monitoring", false)
		hurt_box.set_deferred("monitorable", false)

	# Desativa a colisão física do Boss
	var collision = get_node_or_null("Collision")
	if collision:
		collision.set_deferred("disabled", true)

	# Inicia a animação de morte
	if anim:
		anim.play("Death")

	# Espera a animação terminar
	await get_tree().create_timer(1.2).timeout

	# Boss morreu, jogador venceu
	GameFacade.vitoria()

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
