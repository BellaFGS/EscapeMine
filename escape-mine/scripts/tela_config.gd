extends CanvasLayer

@onready var ctr_geral: HSlider = $ctr_geral

func _ready():

	visible = false

	layer = 100

	ctr_geral.value = db_to_linear(
		MusicManager.musica_fundo.volume_db
	)
func _on_btn_voltar_pressed():
	UIManager.fechar_config()

func _on_ctr_geral_value_changed(value):

	if value <= 0:
		MusicManager.musica_fundo.volume_db = -40
	else:
		MusicManager.musica_fundo.volume_db = linear_to_db(value)
