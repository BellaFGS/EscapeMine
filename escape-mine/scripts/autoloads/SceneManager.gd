extends Node

var cenas: Dictionary = {
	"pause": "res://telas/tela_pause.tscn",
	"main": "res://telas/Sala1.tscn",
	"sala_2": "res://telas/Sala2.tscn",
	"sala_3": "res://telas/sala3.tscn",
	"score": "res://telas/tela_resultado.tscn",
	"inicial": "res://telas/tela_inicial.tscn",
	"level_up": "res://telas/level_up.tscn",
	"config": "res://telas/tela_config.tscn",
	"vitoria": "res://telas/tela_resultado.tscn",
	"morte": "res://telas/tela_resultado.tscn",
	"tutorial_1": "res://telas/tela_tutorial.tscn",
	"tutorial_2": "res://telas/tela_tutorial2.tscn",
	"tutorial_3": "res://telas/tela_tutorial3.tscn",
	"intro": "res://telas/intro_video.tscn",
	"ranking": "res://telas/tela_ranking.tscn"
}


func trocar_cena(nome: String) -> void:
	if not cenas.has(nome):
		push_error("Cena não registrada: " + nome)
		return

	var caminho: String = cenas[nome]

	print("========== DEBUG CENAS ==========")
	print("Sistema operacional: ", OS.get_name())
	print("Caminho solicitado: ", caminho)
	print("ResourceLoader.exists: ", ResourceLoader.exists(caminho))
	print("FileAccess.file_exists: ", FileAccess.file_exists(caminho))

	var diretorio := DirAccess.open("res://telas/")

	if diretorio:
		print("Arquivos encontrados em res://telas/:")

		diretorio.list_dir_begin()

		var arquivo := diretorio.get_next()

		while arquivo != "":
			print("  -> ", arquivo)
			arquivo = diretorio.get_next()

		diretorio.list_dir_end()
	else:
		push_error("Não foi possível abrir res://telas/")

	print("=================================")

	var cena := load(caminho) as PackedScene

	if cena == null:
		push_error("Não foi possível carregar: " + caminho)
		return

	var erro := get_tree().change_scene_to_packed(cena)

	if erro != OK:
		push_error("Falha ao trocar de cena: " + error_string(erro))
