extends CanvasLayer

func _ready() -> void:
	# Garantir que a tela inicial esteja visível ao iniciar o jogo
	visible = true

# Botão COMEÇAR
func _on_btn_comecar_pressed() -> void:
	# Troca para a cena principal do jogo
	# Ajuste o caminho para a cena correta do seu jogo
	get_tree().change_scene_to_file("res://telas/intro_video.tscn")

# Botão SAIR
func _on_btn_sair_pressed() -> void:
	# Fecha o jogo
	get_tree().quit()

# Botão RETOMAR (se quiser usar em pause)
func _on_btn_retomar_pressed() -> void:
	pass # Pode ser implementado se necessário
