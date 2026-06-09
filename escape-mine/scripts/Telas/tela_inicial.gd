extends CanvasLayer

func _ready() -> void:
	print($Tela_Config)
	# Garantir que a tela inicial esteja visível ao iniciar o jogo
	get_tree().paused = false
	visible = true
	AudioManager.tocar_musica("menu")
	
	UIManager.registrar_telas(
	null,
	get_node("Tela_Config")
	)

# Botão COMEÇAR
func _on_btn_comecar_pressed() -> void:
	GameFacade.iniciar_jogo()

# Botão SAIR
func _on_btn_sair_pressed() -> void:
	# Fecha o jogo
	get_tree().quit()


func _on_btn_config_pressed():

	UIManager.abrir_config("menu")

	print($Tela_Config.visible)


func _on_btn_tutorial_pressed() -> void:
	GameFacade.abrir_tutorial_1()
