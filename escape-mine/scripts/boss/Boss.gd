extends "res://scripts/Character.gd"

# --- Strategy pattern: cada ataque é uma estratégia independente ---
# MeleeAttackStrategy, DashAttackStrategy e SummonMinionsStrategy já têm
# "class_name" nos próprios arquivos, então ficam disponíveis globalmente
# em qualquer lugar do projeto - não precisa de preload/const aqui.

## Cena do minion a ser instanciada pela SummonMinionsStrategy (ex: Esqueleto.tscn)
@export var minion_scene: PackedScene

## Distância a partir da qual o boss persegue o player
@export var alcance_perseguicao: float = 550.0

## Distância "confortável" que o boss tenta manter perto do player
## quando nenhuma estratégia de ataque está disponível
@export var distancia_ideal: float = 130.0

var player
var estrategias: Array = []
var estrategia_ativa = null

# Watchdog: se uma estratégia der erro no meio da execução (ex: nó sem
# script, propriedade faltando), ela pode nunca chegar no "is_attack = false"
# e travar o boss pra sempre. Isso aqui força um reset depois de um tempo.
var _tempo_travado_em_ataque: float = 0.0
const TEMPO_MAX_ATAQUE: float = 3.0


func _ready() -> void:
	super._ready()

	# O Character.gd procura o nó de animação como "Animator", mas no
	# boss.tscn ele se chama "Animacao" - reatribuímos aqui, senão "anim"
	# fica apontando pro Animator (que não existe) e vira null.
	anim = get_node_or_null("Animacao")

	# Segurança: se algum campo exportado do Character.gd ficou vazio no
	# Inspector (aparece como "null" no .tscn), evita crash usando um padrão.
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

	if player and is_instance_valid(player):
		virar_para_player()

	for estrategia in estrategias:
		estrategia.atualizar_cooldown(delta)

	# já está no meio de um ataque -> não faz mais nada até terminar
	if is_attack or estrategia_ativa != null:
		_tempo_travado_em_ataque += delta
		if _tempo_travado_em_ataque > TEMPO_MAX_ATAQUE:
			push_warning("Boss: destravando is_attack (provável erro numa estratégia).")
			is_attack = false
			estrategia_ativa = null
			_tempo_travado_em_ataque = 0.0
		return

	_tempo_travado_em_ataque = 0.0

	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return

	var distancia = global_position.distance_to(player.global_position)

	var escolhida = _escolher_estrategia(distancia)

	if escolhida:
		_executar_estrategia(escolhida)
		return

	# nenhum ataque disponível agora -> persegue ou espera
	if distancia > distancia_ideal and distancia <= alcance_perseguicao:
		var direcao = (player.global_position - global_position).normalized()
		mover(direcao)
	else:
		mover(Vector2.ZERO)


## Monta a lista de estratégias disponíveis pra distância atual
## e sorteia uma delas (fácil de trocar por prioridade/peso depois)
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


# --- As animações do boss são só: default / Attack / Dash / Summon / Death,
# então sobrescrevemos a lógica de andar/parar do Character.gd (que usa
# idle_up / walk_down etc, que o boss não tem) ---
func atualizar_animacao(_direcao) -> void:
	if anim == null or is_attack:
		return
	anim.play("default")


## Vira o sprite (flip_h) pra encarar o player, seja ele parado, andando
## ou atacando. Se o sprite original olha pra ESQUERDA por padrão, troque
## o "false"/"true" abaixo (inverta os dois).
func virar_para_player() -> void:
	if anim == null:
		return

	var diferenca_x = player.global_position.x - global_position.x

	if diferenca_x > 1.0:
		anim.flip_h = false   # player à direita -> sprite olha pra direita
	elif diferenca_x < -1.0:
		anim.flip_h = true    # player à esquerda -> sprite olha pra esquerda


func morrer() -> void:
	if esta_morto:
		return
	esta_morto = true
	call_deferred("_morrer_impl")


func _morrer_impl() -> void:
	if anim:
		anim.play("Death")

	var hurt_box = get_node_or_null("hurtBox")
	if hurt_box:
		hurt_box.set_deferred("monitoring", false)

	await get_tree().create_timer(1.2).timeout
	queue_free()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if "forca" in area and "dono" in area:
		receber_dano(area.forca, area.dono.global_position, area.dono)
