extends Node

# ============================================================
# SINAIS
# ============================================================

signal tempo_alterado(valor)
signal modo_controle_alterado(mobile: bool)
signal partida_resetada


# ============================================================
# CONFIGURAÇÕES
# ============================================================

const CAMINHO_CONFIGURACOES := "user://configuracoes.json"

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
# INICIALIZAÇÃO
# ============================================================

func _ready() -> void:
	carregar_modo_controle()


# ============================================================
# CARREGAR MODO DE CONTROLE
# ============================================================

func carregar_modo_controle() -> void:
	if not FileAccess.file_exists(CAMINHO_CONFIGURACOES):
		definir_modo_mobile(false)
		return

	var arquivo := FileAccess.open(
		CAMINHO_CONFIGURACOES,
		FileAccess.READ
	)

	if arquivo == null:
		push_warning("Não foi possível carregar as configurações.")
		definir_modo_mobile(false)
		return

	var conteudo := arquivo.get_as_text()
	arquivo.close()

	var json := JSON.new()

	if json.parse(conteudo) != OK:
		push_warning("Arquivo de configurações inválido.")
		definir_modo_mobile(false)
		return

	var dados = json.data

	if typeof(dados) != TYPE_DICTIONARY:
		definir_modo_mobile(false)
		return

	var mobile: bool = dados.get("modo_mobile", false)

	definir_modo_mobile(mobile)


# ============================================================
# SALVAR MODO DE CONTROLE
# ============================================================

func salvar_modo_controle() -> void:
	var dados: Dictionary = {}

	# Preserva outras configurações existentes.
	if FileAccess.file_exists(CAMINHO_CONFIGURACOES):
		var arquivo_leitura := FileAccess.open(
			CAMINHO_CONFIGURACOES,
			FileAccess.READ
		)

		if arquivo_leitura:
			var json := JSON.new()

			if json.parse(arquivo_leitura.get_as_text()) == OK:
				if typeof(json.data) == TYPE_DICTIONARY:
					dados = json.data

			arquivo_leitura.close()

	dados["modo_mobile"] = modo_mobile

	var arquivo := FileAccess.open(
		CAMINHO_CONFIGURACOES,
		FileAccess.WRITE
	)

	if arquivo == null:
		push_error("Não foi possível salvar o modo de controle.")
		return

	arquivo.store_string(JSON.stringify(dados, "\t"))
	arquivo.close()

	print(
		"Modo de controle salvo: ",
		"Mobile" if modo_mobile else "PC"
	)


# ============================================================
# ALTERAR MODO DE CONTROLE
# ============================================================

func definir_modo_mobile(valor: bool) -> void:
	if _modo_controle_inicializado and modo_mobile == valor:
		return

	modo_mobile = valor
	_modo_controle_inicializado = true

	modo_controle_alterado.emit(modo_mobile)

	print(
		"Modo de controle alterado para: ",
		"Mobile" if modo_mobile else "PC"
	)


func atualizar_modo_controle() -> void:
	modo_controle_alterado.emit(modo_mobile)


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
