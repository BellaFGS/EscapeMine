extends Node

signal pontuacao_alterada(valor: int)

# Banco persistente, compatível com PC, Android e Web.
const CAMINHO_BANCO := "user://escape_mine_ranking.json"

var pontuacao_atual: int = 0
var bonus_boss: int = 0
var bonus_boss_aplicado: bool = false

var resultado_atual: String = ""
var pontuacao_registrada: bool = false
var multiplicador_tempo: int = 1
var penalidade_tentativas: int = 0

var _registros: Array = []


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready() -> void:
	_carregar_banco()


# ============================================================
# PARTIDA
# ============================================================

func iniciar_partida() -> void:
	pontuacao_atual = 0
	bonus_boss = 0
	bonus_boss_aplicado = false

	resultado_atual = ""
	pontuacao_registrada = false
	multiplicador_tempo = 1
	penalidade_tentativas = 0

	pontuacao_alterada.emit(pontuacao_atual)


# ============================================================
# PONTUAÇÃO
# ============================================================

func adicionar_pontos(valor: int) -> void:
	if valor <= 0 or resultado_atual != "":
		return

	pontuacao_atual += valor

	pontuacao_alterada.emit(pontuacao_atual)


func adicionar_bonus_boss(valor: int) -> void:
	if bonus_boss_aplicado:
		return

	if valor <= 0:
		return

	if resultado_atual != "":
		return

	bonus_boss_aplicado = true
	bonus_boss += valor

	adicionar_pontos(valor)


# ============================================================
# FINALIZAÇÃO
# ============================================================

func finalizar_partida(resultado: String) -> void:
	if resultado_atual != "":
		return

	resultado_atual = resultado

	if resultado_atual == "WIN":
		multiplicador_tempo = maxi(
			1,
			calcular_multiplicador_tempo(GameManager.tempo_total)
			- penalidade_tentativas
		)
	else:
		multiplicador_tempo = 1

	print(
		"Partida finalizada: ",
		resultado_atual,
		" | Pontuação: ",
		obter_pontuacao_final()
	)


func calcular_multiplicador_tempo(tempo_segundos: float) -> int:
	if tempo_segundos <= 300.0:
		return 3

	if tempo_segundos <= 600.0:
		return 2

	return 1


func obter_pontuacao_final() -> int:
	return pontuacao_atual * multiplicador_tempo


func restaurar_checkpoint(
	pontos: int,
	bonus: int,
	bonus_aplicado: bool,
	tentativas: int
) -> void:
	pontuacao_atual = pontos
	bonus_boss = bonus
	bonus_boss_aplicado = bonus_aplicado
	penalidade_tentativas = tentativas
	multiplicador_tempo = 1
	resultado_atual = ""
	pontuacao_registrada = false
	pontuacao_alterada.emit(pontuacao_atual)


# ============================================================
# REGISTRO DE PONTUAÇÃO
# ============================================================

func registrar_pontuacao(nome_jogador: String) -> bool:
	if pontuacao_registrada:
		return false

	if resultado_atual == "":
		push_warning("Não existe uma partida finalizada.")
		return false

	var nome_limpo := nome_jogador.strip_edges().to_upper()

	if nome_limpo.is_empty():
		return false

	nome_limpo = nome_limpo.substr(0, 12)

	var novo_registro: Dictionary = {
		"nome": nome_limpo,
		"pontos": obter_pontuacao_final(),
		"multiplicador": multiplicador_tempo,
		"resultado": resultado_atual,
		"data": Time.get_datetime_string_from_system(false, true)
	}

	_registros.append(novo_registro)

	_ordenar_registros()

	# Confirma se o arquivo foi realmente salvo.
	if not _salvar_banco():
		_registros.erase(novo_registro)

		push_error(
			"Não foi possível registrar a pontuação."
		)

		return false

	pontuacao_registrada = true

	print(
		"Pontuação registrada com sucesso: ",
		novo_registro
	)

	return true


# ============================================================
# CONSULTAS
# ============================================================

func obter_ranking(limite: int = 5) -> Array:
	return _registros.slice(
		0,
		mini(limite, _registros.size())
	).duplicate(true)


func obter_todos_registros() -> Array:
	return _registros.duplicate(true)


# ============================================================
# CARREGAR BANCO
# ============================================================

func _carregar_banco() -> void:
	if not FileAccess.file_exists(CAMINHO_BANCO):
		print("Banco de pontuações ainda não existe.")

		_registros = []
		return

	var arquivo := FileAccess.open(
		CAMINHO_BANCO,
		FileAccess.READ
	)

	if arquivo == null:
		push_error(
			"Erro ao abrir banco: ",
			FileAccess.get_open_error()
		)
		return

	var conteudo := arquivo.get_as_text()

	arquivo.close()

	var json := JSON.new()

	var erro := json.parse(conteudo)

	if erro != OK:
		push_warning(
			"Banco de pontuações contém JSON inválido."
		)

		_registros = []
		return

	var dados = json.data

	if dados is Array:
		_registros = dados

		_ordenar_registros()

		print(
			"Banco carregado com ",
			_registros.size(),
			" registros."
		)
	else:
		_registros = []

		push_warning(
			"Formato inválido no banco de pontuações."
		)


# ============================================================
# SALVAR BANCO
# ============================================================

func _salvar_banco() -> bool:
	var arquivo := FileAccess.open(
		CAMINHO_BANCO,
		FileAccess.WRITE
	)

	if arquivo == null:
		push_error(
			"Erro ao abrir banco para escrita: ",
			FileAccess.get_open_error()
		)

		return false

	var conteudo := JSON.stringify(
		_registros,
		"\t"
	)

	arquivo.store_string(conteudo)

	arquivo.flush()

	var erro := arquivo.get_error()

	arquivo.close()

	if erro != OK:
		push_error(
			"Erro ao gravar pontuações: ",
			erro
		)

		return false

	print(
		"Banco salvo com sucesso em: ",
		ProjectSettings.globalize_path(CAMINHO_BANCO)
	)

	return true


# ============================================================
# ORDENAÇÃO
# ============================================================

func _ordenar_registros() -> void:
	_registros.sort_custom(
		func(a, b):
			return int(a.get("pontos", 0)) > int(b.get("pontos", 0))
	)
