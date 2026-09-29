extends Node

signal pontuacao_alterada(valor: int)

const CAMINHO_BANCO := "res://Banco/escape_mine_ranking.json"

var pontuacao_atual: int = 0
var bonus_boss: int = 0
var bonus_boss_aplicado: bool = false
var resultado_atual: String = ""
var pontuacao_registrada: bool = false
var _registros: Array = []


func _ready() -> void:
	_carregar_banco()


func iniciar_partida() -> void:
	pontuacao_atual = 0
	bonus_boss = 0
	bonus_boss_aplicado = false
	resultado_atual = ""
	pontuacao_registrada = false

	pontuacao_alterada.emit(pontuacao_atual)


func adicionar_pontos(valor: int) -> void:
	if valor <= 0 or resultado_atual != "":
		return

	pontuacao_atual += valor
	pontuacao_alterada.emit(pontuacao_atual)


func adicionar_bonus_boss(valor: int) -> void:
	# Impede que o bônus do boss seja aplicado mais de uma vez.
	if bonus_boss_aplicado:
		return

	if valor <= 0:
		return

	bonus_boss_aplicado = true
	bonus_boss += valor

	adicionar_pontos(valor)


func finalizar_partida(resultado: String) -> void:
	resultado_atual = resultado


func registrar_pontuacao(nome_jogador: String) -> bool:
	if pontuacao_registrada:
		return false

	var nome_limpo := nome_jogador.strip_edges().to_upper()

	if nome_limpo.is_empty():
		return false

	nome_limpo = nome_limpo.substr(0, 12)

	_registros.append({
		"nome": nome_limpo,
		"pontos": pontuacao_atual,
		"resultado": resultado_atual,
		"data": Time.get_datetime_string_from_system(false, true),
	})

	_ordenar_registros()
	_salvar_banco()

	pontuacao_registrada = true

	return true


# Retorna os melhores jogadores.
# Por padrão, retorna os 5 melhores.
func obter_ranking(limite: int = 5) -> Array:
	return _registros.slice(
		0,
		mini(limite, _registros.size())
	).duplicate(true)


# Retorna TODOS os registros.
func obter_todos_registros() -> Array:
	return _registros.duplicate(true)


func _carregar_banco() -> void:
	if not FileAccess.file_exists(CAMINHO_BANCO):
		_registros = []
		return

	var arquivo := FileAccess.open(
		CAMINHO_BANCO,
		FileAccess.READ
	)

	if arquivo == null:
		push_warning(
			"Nao foi possivel abrir o banco de pontuacoes."
		)
		return

	var dados = JSON.parse_string(
		arquivo.get_as_text()
	)

	if dados is Array:
		_registros = dados
		_ordenar_registros()
	else:
		_registros = []

		push_warning(
			"Banco de pontuacoes invalido; um novo sera criado."
		)


func _salvar_banco() -> void:
	var arquivo := FileAccess.open(
		CAMINHO_BANCO,
		FileAccess.WRITE
	)

	if arquivo == null:
		push_error(
			"Nao foi possivel salvar o banco de pontuacoes."
		)
		return

	arquivo.store_string(
		JSON.stringify(_registros, "\t")
	)


func _ordenar_registros() -> void:
	_registros.sort_custom(
		func(a, b):
			return int(a.get("pontos", 0)) > int(b.get("pontos", 0))
	)	
