extends Node

var cenas = {
	"pause": "res://telas/tela_pause.tscn",
	"main": "res://telas/main.tscn",
	"inicial": "res://telas/tela_inicial.tscn",
	"level_up": "res://telas/level_up.tscn",
	"config": "res://telas/tela_config.tscn",
	"vitoria": "res://telas/tela_vitoria.tscn",
	"morte": "res://telas/tela_morte.tscn"
}

func trocar_cena(nome):

	if !cenas.has(nome):
		push_error("Cena não encontrada: " + nome)
		return

	get_tree().change_scene_to_file(cenas[nome])
