extends CanvasLayer

func _ready() -> void:
	# A tela já começa visível
	visible = true
	get_tree().paused = false
	AudioManager.tocar_musica("win")

# Botão SAIR
func _on_btn_sair_pressed() -> void:
	AudioManager.tocar_sfx("click")
	GameManager.resetar()
	get_tree().paused = false
	GameFacade.reiniciar_jogo()

func _on_btn_voltar_pressed() -> void:
	AudioManager.tocar_sfx("click")
	GameManager.resetar()
	GameFacade.voltar_menu()
