extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
