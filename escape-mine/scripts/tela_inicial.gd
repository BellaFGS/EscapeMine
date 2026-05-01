extends CanvasLayer

func _ready() -> void:
	# Garantir que a tela inicial esteja visível ao iniciar o jogo
	get_tree().paused = false
	visible = true
	MusicManager.play_music(preload("res://sounds/sons_gameplay/musica_de_fundo.mp3"))

# Botão COMEÇAR
func _on_btn_comecar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# Botão SAIR
func _on_btn_sair_pressed() -> void:
	# Fecha o jogo
	get_tree().quit()


func _on_btn_config_pressed():
	var config_scene = preload("res://telas/tela_config.tscn")
	var config = config_scene.instantiate()
	
	config.origem = "menu"
	
	get_tree().current_scene.add_child(config)
	
	config.visible = true
	visible = false
