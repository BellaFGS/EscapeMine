extends Control

# ============================================================
# REFERÊNCIAS MOBILE
# ============================================================

@onready var joystick_movimento: VirtualJoystick = $"Container/containerMargin/BoxContainerJoystick/MarginContainer/Virtual Joystick"
@onready var btn_upgrade: Button = $Container/containerMargin/BoxContainerButtons/MarginContainer/VSplitContainer/BoxContainerUpgrade/BtnUpgrade
@onready var btn_item: Button = $Container/containerMargin/BoxContainerButtons/MarginContainer/VSplitContainer/BoxContainer/BoxContainerItem/BtnItem
@onready var btn_menu: Button = $Container/containerMargin/BoxContainerMenu/Button
@onready var btn_ataque: Button = $Container/containerMargin/BoxContainerButtons/MarginContainer/VSplitContainer/BoxContainer/BoxContainerAtaque/BtnAtaque


# ============================================================
# REFERÊNCIAS DE UI
# ============================================================

@onready var barra_dano = $Container/containerMargin/MarginContainer2/HSplitContainer/BoxContainerStatus/VSplitContainer/BoxContainerDano/HSplitContainer/BarraDanoTextura

@onready var barra_vida = $Container/containerMargin/MarginContainer2/HSplitContainer/BoxContainerStatus/VSplitContainer/BoxContainerVida/HSplitContainer/BarraVidaTextura

@onready var barra_xp = $Container/containerMargin/BoxContainerBarraXp/BarraXp/BarraXpTextura

@onready var texto_vida = $Container/containerMargin/MarginContainer2/HSplitContainer/BoxContainerStatus/VSplitContainer/BoxContainerVida/HSplitContainer/BarraVidaTextura/TextoVida

@onready var texto_forca = $Container/containerMargin/MarginContainer2/HSplitContainer/BoxContainerStatus/VSplitContainer/BoxContainerDano/HSplitContainer/BarraDanoTextura/TextoForca

@onready var texto_xp = $Container/containerMargin/BoxContainerBarraXp/BarraXp/TextoXp

@onready var texto_nivel = $Container/containerMargin/MarginContainer/BoxContainerAtributos/VSplitContainerAtributos/BoxContainerNivel/PanelNivel/Nivel

@onready var texto_pontos = $Container/containerMargin/MarginContainer2/HSplitContainer/BoxContainerPontos/Pontos

@onready var texto_dinamite = $Container/containerMargin/MarginContainer/BoxContainerAtributos/VSplitContainerAtributos/BoxContainerItemDinamite/PanelItemDinamite/MarginContainer/HSplitContainer/Dinamite

@onready var chave = $Container/containerMargin/MarginContainer/BoxContainerAtributos/VSplitContainerAtributos/BoxContainerItemChave

@onready var texto_upgrade: Label = $Container/containerMargin/BoxContainerUpgrade/TextoUpgrade


# ============================================================
# VARIÁVEIS
# ============================================================

var player = null
var input_manager = null

# Guarda o botão associado a cada dedo.
var _toques_botoes: Dictionary = {}


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready() -> void:
	if not GameManager.modo_controle_alterado.is_connected(
		atualizar_modo_controle
	):
		GameManager.modo_controle_alterado.connect(
			atualizar_modo_controle
		)

	atualizar_modo_controle(GameManager.modo_mobile)

	await get_tree().process_frame

	player = get_tree().get_first_node_in_group("player")

	if player == null:
		push_warning("Player não encontrado no HUD Mobile.")
		return

	input_manager = player.input_manager

	# ========================================================
	# FILTRO DOS CONTAINERS
	# ========================================================

	var containers_para_ignorar: Array[Control] = [
		$Container,
		$Container/containerMargin,
		$Container/containerMargin/MarginContainer,
		$Container/containerMargin/MarginContainer2,
		$Container/containerMargin/BoxContainerBarraXp,
		$Container/containerMargin/BoxContainerJoystick,
		$Container/containerMargin/BoxContainerJoystick/MarginContainer
	]

	for container_ui in containers_para_ignorar:
		if is_instance_valid(container_ui):
			container_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# ========================================================
	# JOYSTICK
	# ========================================================

	if is_instance_valid(joystick_movimento):
		joystick_movimento.mouse_filter = Control.MOUSE_FILTER_STOP

	# ========================================================
	# BOTÕES
	# ========================================================

	var botoes: Array[Button] = [
		btn_upgrade,
		btn_item,
		btn_ataque,
		btn_menu
	]

	for botao in botoes:
		if is_instance_valid(botao):
			botao.focus_mode = Control.FOCUS_NONE
			botao.mouse_filter = Control.MOUSE_FILTER_STOP

	if is_instance_valid(btn_menu):
		if not btn_menu.pressed.is_connected(_on_button_pressed):
			btn_menu.pressed.connect(_on_button_pressed)

	# ========================================================
	# SINAIS DO PLAYER
	# ========================================================

	if not player.vida_alterada.is_connected(atualizar_vida):
		player.vida_alterada.connect(atualizar_vida)

	if not player.forca_alterado.is_connected(atualizar_forca):
		player.forca_alterado.connect(atualizar_forca)

	if not player.dinamite_up.is_connected(atualizar_dinamite):
		player.dinamite_up.connect(atualizar_dinamite)

	# ========================================================
	# SINAIS DOS SISTEMAS
	# ========================================================

	if not UpgradeSystem.xp_alterado.is_connected(atualizar_xp):
		UpgradeSystem.xp_alterado.connect(atualizar_xp)

	if not UpgradeSystem.nivel_up.is_connected(atualizar_nivel):
		UpgradeSystem.nivel_up.connect(atualizar_nivel)

	if not UpgradeSystem.liberar_upgrade.is_connected(mostrar_upgrade):
		UpgradeSystem.liberar_upgrade.connect(mostrar_upgrade)

	if not ScoreManager.pontuacao_alterada.is_connected(atualizar_pontuacao):
		ScoreManager.pontuacao_alterada.connect(atualizar_pontuacao)

	# ========================================================
	# VALORES INICIAIS
	# ========================================================

	atualizar_vida(player.vida)
	atualizar_forca(player.forca)
	atualizar_dinamite(GameManager.player_dinamite)
	atualizar_xp(UpgradeSystem.xp)
	atualizar_nivel(UpgradeSystem.nivel)
	atualizar_pontuacao(ScoreManager.pontuacao_atual)

	mostrar_upgrade(UpgradeSystem.upgrade_disponivel)


# ============================================================
# PROCESSAMENTO
# ============================================================

func _process(_delta: float) -> void:
	if player == null or input_manager == null:
		return

	if not GameManager.modo_mobile:
		return

	if player.item_controller and player.item_controller.usando_item:
		input_manager.limpar_direcao_mobile()
	else:
		if joystick_movimento and joystick_movimento.output.length() > 0.01:
			input_manager.definir_direcao_mobile(
				joystick_movimento.output
			)
		else:
			input_manager.definir_direcao_mobile(Vector2.ZERO)

	atualizar_chave(GameManager.player_tem_chave)
	atualizar_dinamite(GameManager.player_dinamite)


# ============================================================
# MULTITOUCH
# ============================================================

func _input(event: InputEvent) -> void:
	if not GameManager.modo_mobile:
		return

	if event is InputEventScreenTouch:

		var indice_dedo: int = event.index

		if event.pressed:

			# Verifica se o dedo pressionou algum botão.
			var botao: Button = _encontrar_botao(
				event.position
			)

			if botao == null:
				return

			# Associa o dedo ao botão pressionado.
			_toques_botoes[indice_dedo] = botao

		else:

			# Ignora dedos que não iniciaram em botões.
			if not _toques_botoes.has(indice_dedo):
				return

			var botao: Button = _toques_botoes[indice_dedo]

			# Remove somente o dedo que foi solto.
			_toques_botoes.erase(indice_dedo)

			if not is_instance_valid(botao):
				return

			if not botao.is_visible_in_tree():
				return

			if botao.disabled:
				return

			# Aciona somente se o dedo terminou dentro do botão.
			if _ponto_dentro_do_botao(
				botao,
				event.position
			):
				_acionar_botao(botao)

func _encontrar_botao(posicao_tela: Vector2) -> Button:
	var botoes := find_children("*", "Button", true, false)

	for i in range(botoes.size() - 1, -1, -1):
		var botao := botoes[i] as Button

		if botao == null:
			continue

		if not botao.is_visible_in_tree():
			continue

		if botao.disabled:
			continue

		if _ponto_dentro_do_botao(botao, posicao_tela):
			return botao

	return null


func _ponto_dentro_do_botao(
	botao: Button,
	posicao_tela: Vector2
) -> bool:
	var transformacao := botao.get_global_transform_with_canvas()
	var posicao_local := transformacao.affine_inverse() * posicao_tela

	return Rect2(
		Vector2.ZERO,
		botao.size
	).has_point(posicao_local)


func _acionar_botao(botao: Button) -> void:
	if botao == btn_upgrade:
		_on_btn_upgrade_pressed()

	elif botao == btn_item:
		_on_btn_item_pressed()

	elif botao == btn_ataque:
		_on_btn_ataque_pressed()

	elif botao == btn_menu:
		_on_button_pressed()

# ============================================================
# MODO DE CONTROLE
# ============================================================

func atualizar_modo_controle(mobile: bool) -> void:
	visible = mobile
	set_process(mobile)

	if not mobile and input_manager != null:
		input_manager.limpar_direcao_mobile()

	if not mobile:
		_toques_botoes.clear()


# ============================================================
# ATUALIZAÇÕES VISUAIS
# ============================================================

func atualizar_vida(valor: int) -> void:
	if player == null:
		return

	if barra_vida:
		barra_vida.max_value = player.vida_max
		barra_vida.value = valor

	if texto_vida:
		texto_vida.text = str(valor) + "/" + str(player.vida_max)


func atualizar_forca(valor: int) -> void:
	if barra_dano:
		barra_dano.value = valor

	if texto_forca:
		texto_forca.text = str(valor)


func atualizar_xp(valor: int) -> void:
	if barra_xp:
		barra_xp.max_value = UpgradeSystem.limite
		barra_xp.value = valor

	if texto_xp:
		texto_xp.text = str(valor) + "/" + str(UpgradeSystem.limite)


func atualizar_nivel(valor: int) -> void:
	if texto_nivel:
		texto_nivel.text = str(valor)


func atualizar_dinamite(valor: int) -> void:
	if texto_dinamite:
		texto_dinamite.text = str(valor)


func atualizar_chave(possui_chave: bool) -> void:
	if chave:
		chave.visible = possui_chave


func atualizar_pontuacao(valor: int) -> void:
	if texto_pontos:
		texto_pontos.text = "SCORE  %07d" % valor


# ============================================================
# UPGRADE
# ============================================================

func mostrar_upgrade(valor: bool) -> void:
	if texto_upgrade:
		texto_upgrade.visible = valor

	if btn_upgrade:
		btn_upgrade.visible = valor


func ocultar_upgrade() -> void:
	if texto_upgrade:
		texto_upgrade.visible = false

	if btn_upgrade:
		btn_upgrade.visible = false


# ============================================================
# BOTÕES
# ============================================================

func _on_btn_upgrade_pressed() -> void:
	if not UpgradeSystem.upgrade_disponivel:
		return

	GameFacade.abrir_upgrade()


func _on_btn_item_pressed() -> void:
	if player == null or player.item_controller == null:
		return

	player.item_controller.usar_dinamite()


func _on_btn_ataque_pressed() -> void:
	if player == null or player.is_attack:
		return

	player.atacar()


func _on_button_pressed() -> void:
	UIManager.abrir_pause()
