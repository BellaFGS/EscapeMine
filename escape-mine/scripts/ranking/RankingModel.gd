extends Node

var registros: Array = []


# ============================================================
# CARREGAR REGISTROS
# ============================================================

func carregar_registros() -> void:
	registros = ScoreManager.obter_todos_registros()

	print(
		"RankingModel: ",
		registros.size(),
		" registros carregados."
	)


# ============================================================
# OBTER REGISTROS
# ============================================================

func obter_registros() -> Array:
	carregar_registros()

	return registros.duplicate(true)
