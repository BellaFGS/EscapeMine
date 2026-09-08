extends Node

var model
var view


func inicializar(_model, _view) -> void:
	model = _model
	view = _view

	carregar_ranking()


func carregar_ranking() -> void:
	var registros: Array = model.obter_registros()

	view.exibir_ranking(registros)


func voltar_menu() -> void:
	SceneManager.trocar_cena("inicial")
