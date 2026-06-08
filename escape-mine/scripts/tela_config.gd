extends CanvasLayer

@onready var ctr_geral: HSlider = $Menu_Vertical/Menu_Horizontal/Barras/ctr_geral
@onready var ctr_sfx: HSlider = $Menu_Vertical/Menu_Horizontal/Barras/ctr_sfx
@onready var ctr_musica: HSlider = $Menu_Vertical/Menu_Horizontal/Barras/ctr_musica


func _ready():
	visible = false
	layer = 100
	AudioManager.tocar_musica("pause")

	ctr_geral.value = AudioManager.volume_master
	ctr_musica.value = AudioManager.volume_musica
	ctr_sfx.value = AudioManager.volume_sfx

func _on_btn_voltar_pressed():
	UIManager.fechar_config()

func _on_ctr_geral_value_changed(value):
	AudioManager.definir_volume_master(value)

func _on_ctr_musica_value_changed(value):
	AudioManager.definir_volume_musica(value)

func _on_ctr_sfx_value_changed(value):
	AudioManager.definir_volume_sfx(value)
