extends Node

const CAMINHO_BANCO := "res://Banco/escape_mine_ranking.json"

var registros: Array = []


func carregar_registros() -> void:
	registros.clear()

	if not FileAccess.file_exists(CAMINHO_BANCO):
		return

	var arquivo := FileAccess.open(CAMINHO_BANCO, FileAccess.READ)

	if arquivo == null:
		push_warning("Não foi possível abrir o banco de rankings.")
		return

	var dados = JSON.parse_string(arquivo.get_as_text())

	if dados is Array:
		registros = dados.duplicate(true)


func obter_registros() -> Array:
	carregar_registros()
	return registros.duplicate(true)
