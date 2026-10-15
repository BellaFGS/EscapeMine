extends Node

signal tempo_alterado(valor)
signal modo_controle_alterado(mobile: bool)
signal partida_resetada


var tempo_total: float = 0.0
var modo_mobile: bool = false
var _modo_controle_inicializado: bool = false


# ============================================================
# ESTADO DA PARTIDA
# ============================================================

var player_tem_chave: bool = false
var estado: String = "RUNNING"
var upgrade_pendente: String = ""


# ============================================================
# ATRIBUTOS PERSISTENTES DO PLAYER
# ============================================================

var player_vida_max: int = 100
var player_forca: int = 1
var player_dinamite: int = 0


# ============================================================
# INICIALIZAÇÃO E DETECÇÃO DO DISPOSITIVO
# ============================================================

func _ready() -> void:
	atualizar_modo_controle()


func detectar_modo_mobile() -> bool:
	# Android sempre utiliza o HUD mobile.
	if OS.has_feature("android"):
		return true

	# iOS também utiliza o HUD mobile.
	if OS.has_feature("ios"):
		return true

	# Outras plataformas utilizam o HUD de PC por padrão.
	return false


func atualizar_modo_controle() -> void:
	definir_modo_mobile(detectar_modo_mobile())


func definir_modo_mobile(valor: bool) -> void:
	if _modo_controle_inicializado and modo_mobile == valor:
		return

	modo_mobile = valor
	_modo_controle_inicializado = true

	modo_controle_alterado.emit(modo_mobile)

	print(
		"Modo de controle: ",
		"Mobile" if modo_mobile else "PC"
	)


# ============================================================
# PROCESSAMENTO
# ============================================================

func _process(delta: float) -> void:
	if estado != "RUNNING":
		return

	tempo_total += delta
	tempo_alterado.emit(tempo_total)


# ============================================================
# CHAVE
# ============================================================

func pegar_chave() -> void:
	player_tem_chave = true
	print("Player pegou a chave.")


func resetar_chave() -> void:
	player_tem_chave = false
	print("Chave resetada.")


func tem_chave() -> bool:
	return player_tem_chave


func resetarChave() -> void:
	player_tem_chave = false


# ============================================================
# ATRIBUTOS DO PLAYER
# ============================================================

func salvar_atributos_player(player) -> void:
	player_vida_max = player.vida_max
	player_forca = player.forca

	if player.inventario:
		player_dinamite = player.inventario.quantidade_item(
			"dinamite"
		)


func carregar_atributos_player(player) -> void:
	player.vida_max = player_vida_max
	player.vida = player_vida_max
	player.forca = player_forca


# ============================================================
# FINALIZAÇÃO
# ============================================================

func finalizar_jogo(resultado: String) -> void:
	estado = resultado

	ScoreManager.finalizar_partida(resultado)

	print("Fim de jogo: ", resultado)

	if resultado == "WIN":
		GameFacade.vitoria()
	elif resultado == "LOSE":
		GameFacade.game_over()


# ============================================================
# RESET DA PARTIDA
# ============================================================

func resetar() -> void:
	print("Resetando estado do jogo...")

	estado = "RUNNING"
	tempo_total = 0.0
	player_tem_chave = false
	upgrade_pendente = ""

	player_vida_max = 100
	player_forca = 1
	player_dinamite = 0

	ScoreManager.iniciar_partida()
	UpgradeSystem.resetar()

	partida_resetada.emit()

	print("Estado do jogo resetado.")
