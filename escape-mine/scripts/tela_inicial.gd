extends CanvasLayer

# Chamado quando o nó entra na árvore de cena
func _ready() -> void:
	# Garantir que a tela inicial esteja visível ao iniciar o jogo
	visible = true

# Botão COMEÇAR
func _on_btn_comecar_pressed() -> void:
	# Troca para a cena principal do jogo
	# Substitua pelo caminho correto da sua cena de jogo
	get_tree().change_scene("res://cenas/world_one.tscn")

# Botão SAIR
func _on_btn_sair_pressed() -> void:
	# Fecha o jogo
	get_tree().quit()


func _on_btn_retomar_pressed() -> void:
	pass # Replace with function body.
