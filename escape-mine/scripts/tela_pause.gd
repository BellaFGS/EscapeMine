extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	MusicManager.play_music(preload("res://sounds/sons_gameplay/musica_de_fundo.mp3"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = true
		get_tree().paused = true

# voltar ao world one e adicionar uma corrente e adicionar a tela_pause
func _on_btn_retomar_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_btn_sair_pressed() -> void:
	get_tree().quit()

func _on_btn_config_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://telas/tela_config.tscn")
