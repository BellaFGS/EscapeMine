extends CanvasLayer



# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = !visible
		get_tree().paused = visible

# voltar ao world one e adicionar uma corrente e adicionar a tela_pause
func _on_btn_retomar_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_btn_sair_pressed() -> void:
	get_tree().quit()

# botão config (no pause)
func _on_btn_config_pressed():
	var config = get_parent().get_node("Tela_Config")
	config.origem = "pause"
	config.visible = true
	visible = false


func _on_btn_inicio_pressed() -> void:
	get_tree().change_scene_to_file("res://telas/tela_inicial.tscn")
