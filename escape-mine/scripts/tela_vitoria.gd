extends CanvasLayer

func _ready() -> void:
	# A tela já começa visível
	visible = true

# Botão SAIR
func _on_btn_sair_pressed() -> void:
	get_tree().quit()
