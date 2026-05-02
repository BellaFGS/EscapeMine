extends CanvasLayer

@onready var ctr_geral: HSlider = $ctr_geral
var origem = ""

func _ready() -> void:
	# sincroniza o slider com o volume atual
	ctr_geral.value = db_to_linear(MusicManager.musica_fundo.volume_db)

func _on_btn_voltar_pressed() -> void:
	match origem:
		"pause":
			visible = false
			get_parent().get_node("Tela_Pause").visible = true
		
		"menu":
			get_tree().change_scene_to_file("res://telas/tela_inicial.tscn")
		
		_:
			print("Origem não definida")

func _on_ctr_geral_value_changed(value: float) -> void:
	if value <= 0:
		MusicManager.musica_fundo.volume_db = -40
	else:
		MusicManager.musica_fundo.volume_db = linear_to_db(value)
