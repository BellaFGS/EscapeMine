extends CanvasLayer

const LIMITE_MOBILE := 800

@onready var ctr_geral: HSlider = $BoxContainer/fundo_tela/MarginContainer/BoxContainer/VSplitContainer/BoxContainer/HSplitContainer/VSplitContainer2/ctr_geral
@onready var ctr_sfx: HSlider = $BoxContainer/fundo_tela/MarginContainer/BoxContainer/VSplitContainer/BoxContainer/HSplitContainer/VSplitContainer2/ctr_sfx
@onready var ctr_musica: HSlider = $BoxContainer/fundo_tela/MarginContainer/BoxContainer/VSplitContainer/BoxContainer/HSplitContainer/VSplitContainer2/ctr_musica
@onready var seletor_controle: OptionButton = $BoxContainer/fundo_tela/MarginContainer/BoxContainer/VSplitContainer/BoxContainer/HSplitContainer/VSplitContainer2/SeletorControle


func _ready() -> void:
	visible = false
	layer = 100

	AudioManager.tocar_musica("pause")

	ctr_geral.value = AudioManager.volume_master
	ctr_musica.value = AudioManager.volume_musica
	ctr_sfx.value = AudioManager.volume_sfx

	seletor_controle.clear()
	seletor_controle.add_item("PC")
	seletor_controle.add_item("Mobile")

	_configurar_controle_inicial()


func _configurar_controle_inicial() -> void:
	var tamanho_tela := get_viewport().get_visible_rect().size

	var eh_mobile := (
		DisplayServer.is_touchscreen_available()
		or OS.has_feature("android")
		or OS.has_feature("ios")
		or tamanho_tela.x < LIMITE_MOBILE
		or tamanho_tela.y < LIMITE_MOBILE
	)

	GameManager.definir_modo_mobile(eh_mobile)

	seletor_controle.select(1 if eh_mobile else 0)


func _on_btn_voltar_pressed() -> void:
	AudioManager.tocar_sfx("click")
	UIManager.fechar_config()


func _on_ctr_geral_value_changed(value: float) -> void:
	AudioManager.definir_volume_master(value)


func _on_ctr_musica_value_changed(value: float) -> void:
	AudioManager.definir_volume_musica(value)


func _on_ctr_sfx_value_changed(value: float) -> void:
	AudioManager.definir_volume_sfx(value)


func _on_seletor_controle_item_selected(index: int) -> void:
	GameManager.definir_modo_mobile(index == 1)
