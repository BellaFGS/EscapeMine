extends CanvasLayer

# ============================================================
# CONFIGURAÇÕES
# ============================================================

const CAMINHO_ARQUIVO := "user://configuracoes.json"


# ============================================================
# REFERÊNCIAS
# ============================================================

@onready var ctr_geral: HSlider = $BoxContainer/fundo_tela/MarginContainer/BoxContainer/VSplitContainer/BoxContainer/HSplitContainer/VSplitContainer2/ctr_geral

@onready var ctr_sfx: HSlider = $BoxContainer/fundo_tela/MarginContainer/BoxContainer/VSplitContainer/BoxContainer/HSplitContainer/VSplitContainer2/ctr_sfx

@onready var ctr_musica: HSlider = $BoxContainer/fundo_tela/MarginContainer/BoxContainer/VSplitContainer/BoxContainer/HSplitContainer/VSplitContainer2/ctr_musica

@onready var seletor_controle: OptionButton = $BoxContainer/fundo_tela/MarginContainer/BoxContainer/VSplitContainer/BoxContainer/HSplitContainer/VSplitContainer2/SeletorControle


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready() -> void:
	visible = false
	layer = 100

	AudioManager.tocar_musica("pause")

	# Configura as opções disponíveis.
	#seletor_controle.clear()
#
	#seletor_controle.add_item("PC", 0)
	#seletor_controle.add_item("Mobile", 1)

	# Garante que o sinal esteja conectado.
	if not seletor_controle.item_selected.is_connected(
		_on_seletor_controle_item_selected
	):
		seletor_controle.item_selected.connect(
			_on_seletor_controle_item_selected
		)

	# Carrega as configurações.
	carregar_configuracoes()


# ============================================================
# SALVAR CONFIGURAÇÕES
# ============================================================

func salvar_configuracoes() -> void:
	var dados := {
		"volume_master": AudioManager.volume_master,
		"volume_musica": AudioManager.volume_musica,
		"volume_sfx": AudioManager.volume_sfx,
		"modo_mobile": GameManager.modo_mobile
	}

	var arquivo := FileAccess.open(
		CAMINHO_ARQUIVO,
		FileAccess.WRITE
	)

	if arquivo == null:
		push_error(
			"Erro ao salvar configurações: ",
			FileAccess.get_open_error()
		)
		return

	arquivo.store_string(JSON.stringify(dados, "\t"))
	arquivo.close()

	print("Configurações salvas com sucesso.")


# ============================================================
# CARREGAR CONFIGURAÇÕES
# ============================================================

func carregar_configuracoes() -> void:
	if not FileAccess.file_exists(CAMINHO_ARQUIVO):
		_aplicar_valores_padrao()
		return

	var arquivo := FileAccess.open(
		CAMINHO_ARQUIVO,
		FileAccess.READ
	)

	if arquivo == null:
		push_warning("Não foi possível abrir as configurações.")
		_aplicar_valores_padrao()
		return

	var conteudo := arquivo.get_as_text()
	arquivo.close()

	var json := JSON.new()

	if json.parse(conteudo) != OK:
		push_warning("JSON de configurações inválido.")
		_aplicar_valores_padrao()
		return

	var dados = json.data

	if typeof(dados) != TYPE_DICTIONARY:
		_aplicar_valores_padrao()
		return

	# ========================================================
	# VOLUMES
	# ========================================================

	var vol_master: float = float(
		dados.get("volume_master", AudioManager.volume_master)
	)

	var vol_musica: float = float(
		dados.get("volume_musica", AudioManager.volume_musica)
	)

	var vol_sfx: float = float(
		dados.get("volume_sfx", AudioManager.volume_sfx)
	)

	AudioManager.definir_volume_master(vol_master)
	AudioManager.definir_volume_musica(vol_musica)
	AudioManager.definir_volume_sfx(vol_sfx)

	# Atualiza os sliders sem disparar seus sinais.
	ctr_geral.set_value_no_signal(vol_master)
	ctr_musica.set_value_no_signal(vol_musica)
	ctr_sfx.set_value_no_signal(vol_sfx)

	# ========================================================
	# MODO DE CONTROLE
	# ========================================================

	var mobile: bool = dados.get(
		"modo_mobile",
		GameManager.modo_mobile
	)

	GameManager.definir_modo_mobile(mobile)

	# Atualiza visualmente o OptionButton.
	seletor_controle.select(1 if mobile else 0)

	print(
		"Configurações carregadas. Controle: ",
		"Mobile" if mobile else "PC"
	)


# ============================================================
# VALORES PADRÃO
# ============================================================

func _aplicar_valores_padrao() -> void:
	ctr_geral.set_value_no_signal(
		AudioManager.volume_master
	)

	ctr_musica.set_value_no_signal(
		AudioManager.volume_musica
	)

	ctr_sfx.set_value_no_signal(
		AudioManager.volume_sfx
	)

	# Usa o modo já carregado pelo GameManager.
	seletor_controle.select(
		1 if GameManager.modo_mobile else 0
	)


# ============================================================
# ALTERAR MODO DE CONTROLE
# ============================================================

func _on_seletor_controle_item_selected(index: int) -> void:
	var mobile: bool = index == 1

	# Atualiza o modo imediatamente.
	GameManager.definir_modo_mobile(mobile)

	# Salva a escolha.
	salvar_configuracoes()

	print(
		"Usuário selecionou: ",
		"Mobile" if mobile else "PC"
	)


# ============================================================
# VOLUME GERAL
# ============================================================

func _on_ctr_geral_value_changed(value: float) -> void:
	AudioManager.definir_volume_master(value)
	salvar_configuracoes()


# ============================================================
# VOLUME MÚSICA
# ============================================================

func _on_ctr_musica_value_changed(value: float) -> void:
	AudioManager.definir_volume_musica(value)
	salvar_configuracoes()


# ============================================================
# VOLUME SFX
# ============================================================

func _on_ctr_sfx_value_changed(value: float) -> void:
	AudioManager.definir_volume_sfx(value)
	salvar_configuracoes()


# ============================================================
# BOTÃO VOLTAR
# ============================================================

func _on_btn_voltar_pressed() -> void:
	AudioManager.tocar_sfx("click")

	salvar_configuracoes()

	UIManager.fechar_config()
