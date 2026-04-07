extends CanvasLayer

func _ready() -> void:
	# A tela de morte já começa visível
	visible = true
	get_tree().paused = true

# Botão SAIR
func _on_btn_sair_pressed() -> void:
	get_tree().quit()


func _on_btn_voltar_pressed() -> void:
	GameManager.resetar()
	get_tree().paused = false
	get_tree().reload_current_scene()
	#get_tree().change_scene_to_file("res://telas/tela_inicial.tscn")
