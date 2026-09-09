extends Control

@onready var lista_ranking: VBoxContainer = $BoxContainer/PainelRanking/BoxContainer2/VSplitContainer/ScrollContainer/ListaRanking
@onready var botao_voltar: Button = $BoxContainer/PainelRanking/BoxContainer2/VSplitContainer/MarginContainer/btn_voltar

@onready var model = $RankingModel
@onready var controller = $RankingController

const ITEM_RANKING = preload("res://telas/ranking_item.tscn")


func _ready() -> void:

	controller.inicializar(model, self)


func exibir_ranking(registros: Array) -> void:
	for filho in lista_ranking.get_children():
		filho.queue_free()

	for registro in registros:
		var item = ITEM_RANKING.instantiate()
		lista_ranking.add_child(item)

		item.configurar(registro)

func _on_btn_voltar_pressed() -> void:
	AudioManager.tocar_sfx("click")
	controller.voltar_menu()
