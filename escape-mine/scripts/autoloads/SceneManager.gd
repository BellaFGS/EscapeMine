extends Node

var cenas = {
	"pause": "res://telas/tela_pause.tscn",
	"main": "res://telas/sala1.tscn",
	"sala_2": "res://telas/sala2.tscn",
	"sala_3": "res://telas/sala3.tscn",
	"inicial": "res://telas/tela_inicial.tscn",
	"level_up": "res://telas/level_up.tscn",
	"config": "res://telas/tela_config.tscn",
	"vitoria": "res://telas/tela_vitoria.tscn",
	"morte": "res://telas/tela_morte.tscn",
	"tutorial_1": "res://telas/tela_tutorial.tscn",
	"tutorial_2": "res://telas/tela_tutorial2.tscn",
	"tutorial_3": "res://telas/tela_tutorial3.tscn"
}

func trocar_cena(nome):

	if !cenas.has(nome):
		push_error("Cena não encontrada: " + nome)
		return

	get_tree().change_scene_to_file(cenas[nome])
