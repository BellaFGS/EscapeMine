extends CanvasLayer

func _ready() -> void:
	# A tela já começa visível
	visible = true
	get_tree().paused = false

# Botão SAIR
func _on_btn_sair_pressed() -> void:
	GameManager.resetar()
	get_tree().paused = false
	GameFacade.reiniciar_jogo()

func _on_btn_voltar_pressed() -> void:
	GameManager.resetar()
	GameFacade.voltar_menu()
