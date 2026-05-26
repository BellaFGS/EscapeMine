extends CanvasLayer

var musica_anterior := ""

func _ready():

	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _input(event):

	if event.is_action_pressed("ui_cancel"):

		visible = !visible

		get_tree().paused = visible

		if visible:

			# salva música atual
			musica_anterior = AudioManager.musica_player.stream.resource_path

			AudioManager.tocar_musica("pause")

		else:

			voltar_musica_jogo()

func voltar_musica_jogo():

	if musica_anterior.contains("bgMain"):
		AudioManager.tocar_musica("main")

	elif musica_anterior.contains("bgMenu"):
		AudioManager.tocar_musica("menu")

	elif musica_anterior.contains("bgWin"):
		AudioManager.tocar_musica("win")

	elif musica_anterior.contains("dieSong"):
		AudioManager.tocar_musica("gameOver")

func _on_btn_retomar_pressed() -> void:

	get_tree().paused = false
	visible = false

	voltar_musica_jogo()

func _on_btn_sair_pressed() -> void:
	get_tree().quit()

func _on_btn_config_pressed():
	AudioManager.tocar_sfx("click")
	UIManager.abrir_config("pause")

func _on_btn_inicio_pressed() -> void:
	AudioManager.tocar_sfx("click")
	get_tree().paused = false

	AudioManager.tocar_musica("menu")

	GameFacade.voltar_menu()
