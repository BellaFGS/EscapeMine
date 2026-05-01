extends CanvasLayer

func _ready() -> void:
	# Garantir que a tela inicial esteja visível ao iniciar o jogo
	visible = true
	MusicManager.play_music(preload("res://sounds/sons_gameplay/musica_de_fundo.mp3"))

# Botão COMEÇAR
func _on_btn_comecar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# Botão SAIR
func _on_btn_sair_pressed() -> void:
	# Fecha o jogo
	get_tree().quit()


func _on_btn_config_pressed() -> void:
	get_tree().paused = false
	visible = false
