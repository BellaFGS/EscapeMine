extends CanvasLayer

func _ready() -> void:
	# A tela de morte já começa visível
	visible = true

# Botão SAIR
func _on_btn_sair_pressed() -> void:
	get_tree().quit()

# Botão REINICIAR
func _on_btn_reiniciar_pressed() -> void:
	# Reinicia a cena principal do jogo sem voltar para a tela inicial
	get_tree().paused = false
	get_tree().reload_current_scene()
