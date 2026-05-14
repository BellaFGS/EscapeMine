extends Node

var origem_config = ""
var tela_pause = null
var tela_config = null

func registrar_telas(pause, config):
	tela_pause = pause
	tela_config = config

func abrir_config(origem):
	origem_config = origem
	if tela_pause:
		tela_pause.visible = false
	if tela_config:
		tela_config.visible = true

func fechar_config():
	if !tela_config:
		return

	tela_config.visible = false
	match origem_config:
		"pause":
			if tela_pause:
				tela_pause.visible = true
		"menu":
			SceneManager.trocar_cena("inicial")
		_:
			push_warning("Origem da config não definida")
