extends Node

var model: Node
var view: Control


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func inicializar(_model: Node, _view: Control) -> void:
	model = _model
	view = _view

	carregar_ranking()


# ============================================================
# CARREGAR RANKING
# ============================================================

func carregar_ranking() -> void:
	if model == null or view == null:
		push_error("RankingController: Model ou View não inicializados.")
		return

	var registros: Array = model.obter_registros()

	print(
		"RankingController: ",
		registros.size(),
		" registros encontrados."
	)

	view.exibir_ranking(registros)


# ============================================================
# VOLTAR AO MENU
# ============================================================

func voltar_menu() -> void:
	SceneManager.trocar_cena("inicial")
