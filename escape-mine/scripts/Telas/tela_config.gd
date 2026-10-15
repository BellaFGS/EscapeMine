extends CanvasLayer

const CAMINHO_PASTA := "res://Banco/"
const CAMINHO_ARQUIVO := "res://Banco/configuracoes.json"

@onready var ctr_geral: HSlider = $BoxContainer/fundo_tela/MarginContainer/BoxContainer/VSplitContainer/BoxContainer/HSplitContainer/VSplitContainer2/ctr_geral
@onready var ctr_sfx: HSlider = $BoxContainer/fundo_tela/MarginContainer/BoxContainer/VSplitContainer/BoxContainer/HSplitContainer/VSplitContainer2/ctr_sfx
@onready var ctr_musica: HSlider = $BoxContainer/fundo_tela/MarginContainer/BoxContainer/VSplitContainer/BoxContainer/HSplitContainer/VSplitContainer2/ctr_musica
@onready var seletor_controle: OptionButton = $BoxContainer/fundo_tela/MarginContainer/BoxContainer/VSplitContainer/BoxContainer/HSplitContainer/VSplitContainer2/SeletorControle


func _ready() -> void:
	visible = false
	layer = 100

	AudioManager.tocar_musica("pause")

	seletor_controle.clear()
	seletor_controle.add_item("PC")
	seletor_controle.add_item("Mobile")

	# Carrega as configurações salvas ou define o padrão
	carregar_configuracoes()


func _configurar_controle_inicial(modo_mobile_salvo: bool) -> void:
	GameManager.definir_modo_mobile(modo_mobile_salvo)
	seletor_controle.select(1 if modo_mobile_salvo else 0)


func salvar_configuracoes() -> void:
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("Banco"):
		dir.make_dir("Banco")

	var dados = {
		"volume_master": AudioManager.volume_master,
		"volume_musica": AudioManager.volume_musica,
		"volume_sfx": AudioManager.volume_sfx,
		"modo_mobile": GameManager.modo_mobile
	}

	var arquivo = FileAccess.open(CAMINHO_ARQUIVO, FileAccess.WRITE)
	if arquivo:
		var json_string = JSON.stringify(dados)
		arquivo.store_string(json_string)
		arquivo.close()


func carregar_configuracoes() -> void:
	if FileAccess.file_exists(CAMINHO_ARQUIVO):
		var arquivo = FileAccess.open(CAMINHO_ARQUIVO, FileAccess.READ)
		if arquivo:
			var json = JSON.new()
			var erro = json.parse(arquivo.get_as_text())
			arquivo.close()

			if erro == OK:
				var dados = json.get_data()
				if typeof(dados) == TYPE_DICTIONARY:
					# Aplica os volumes salvos
					var vol_master = dados.get("volume_master", 1.0)
					var vol_musica = dados.get("volume_musica", 1.0)
					var vol_sfx = dados.get("volume_sfx", 1.0)

					AudioManager.definir_volume_master(vol_master)
					AudioManager.definir_volume_musica(vol_musica)
					AudioManager.definir_volume_sfx(vol_sfx)

					ctr_geral.value = vol_master
					ctr_musica.value = vol_musica
					ctr_sfx.value = vol_sfx

					# Aplica o modo de controle salvo (padrão desktop falso caso não exista)
					var mobile = dados.get("modo_mobile", false)
					_configurar_controle_inicial(mobile)
					return

	# Valores padrão caso o arquivo ainda não exista
	ctr_geral.value = AudioManager.volume_master
	ctr_musica.value = AudioManager.volume_musica
	ctr_sfx.value = AudioManager.volume_sfx
	_configurar_controle_inicial(false)


func _on_btn_voltar_pressed() -> void:
	AudioManager.tocar_sfx("click")
	salvar_configuracoes() # Salva automaticamente ao fechar/voltar das configurações
	UIManager.fechar_config()


func _on_ctr_geral_value_changed(value: float) -> void:
	AudioManager.definir_volume_master(value)
	salvar_configuracoes()


func _on_ctr_musica_value_changed(value: float) -> void:
	AudioManager.definir_volume_musica(value)
	salvar_configuracoes()


func _on_ctr_sfx_value_changed(value: float) -> void:
	AudioManager.definir_volume_sfx(value)
	salvar_configuracoes()


func _on_seletor_controle_item_selected(index: int) -> void:
	GameManager.definir_modo_mobile(index == 1)
	salvar_configuracoes()
