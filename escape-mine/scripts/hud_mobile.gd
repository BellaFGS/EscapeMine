extends Control


# ============================================================
# REFERÊNCIAS MOBILE (JOYSTICK E BOTÕES)
# ============================================================
@onready var joystick_movimento: VirtualJoystick = $"Container/containerMargin/BoxContainerJoystick/MarginContainer/Virtual Joystick"
@onready var btn_upgrade: Button = $Container/containerMargin/BoxContainerButtons/MarginContainer/VSplitContainer/BoxContainerUpgrade/BtnUpgrade
@onready var btn_item: Button = $Container/containerMargin/BoxContainerButtons/MarginContainer/VSplitContainer/BoxContainer/BoxContainerItem/BtnItem
@onready var btn_menu: Button = $Container/containerMargin/BoxContainerMenu/Button

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


var player
var input_manager


func _ready() -> void:

	await get_tree().process_frame

	player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("Player não encontrado no HUD Mobile")
		return

	input_manager = player.input_manager

	# ========================================================
	# 1. DESATIVA O BLOQUEIO DE MOUSE EM TODOS OS CONTAINERS PAIS
	# ========================================================
	var containers_para_ignorar = [
		$Container,
		$Container/containerMargin,
		$Container/containerMargin/MarginContainer,
		$Container/containerMargin/MarginContainer2,
		$Container/containerMargin/BoxContainerBarraXp,
		$Container/containerMargin/BoxContainerJoystick,
		$Container/containerMargin/BoxContainerJoystick/MarginContainer
	]

	for c in containers_para_ignorar:
		if c:
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# ========================================================
	# 2. TRAZ O JOYSTICK PARA A FRENTE E ATIVA A RECEPÇÃO
	# ========================================================
	if joystick_movimento:
		joystick_movimento.move_to_front()
		joystick_movimento.mouse_filter = Control.MOUSE_FILTER_STOP

	# ========================================================
	# 3. CONFIGURAÇÃO DO BOTÃO DE MENU E DEMAIS BOTÕES
	# ========================================================
	if btn_menu:
		btn_menu.focus_mode = Control.FOCUS_NONE
		btn_menu.mouse_filter = Control.MOUSE_FILTER_STOP

		var container_menu = $Container/containerMargin/BoxContainerMenu
		if container_menu:
			container_menu.move_to_front()

		if not btn_menu.pressed.is_connected(_on_button_pressed):
			btn_menu.pressed.connect(_on_button_pressed)

	if btn_upgrade:
		btn_upgrade.focus_mode = Control.FOCUS_NONE
	
	if btn_item:
		btn_item.focus_mode = Control.FOCUS_NONE

	# ========================================================
	# SINAIS DO PLAYER E SISTEMAS
	# ========================================================
	player.vida_alterada.connect(atualizar_vida)
	player.forca_alterado.connect(atualizar_forca)
	player.dinamite_up.connect(atualizar_dinamite)

	UpgradeSystem.xp_alterado.connect(atualizar_xp)
	UpgradeSystem.nivel_up.connect(atualizar_nivel)
	UpgradeSystem.liberar_upgrade.connect(mostrar_upgrade)
	ScoreManager.pontuacao_alterada.connect(atualizar_pontuacao)

	# Atualização inicial
	atualizar_vida(player.vida)
	atualizar_forca(player.forca)
	atualizar_dinamite(GameManager.player_dinamite)
	atualizar_xp(UpgradeSystem.xp)
	atualizar_nivel(UpgradeSystem.nivel)
	atualizar_pontuacao(ScoreManager.pontuacao_atual)

	ocultar_upgrade()

	GameManager.modo_controle_alterado.connect(atualizar_modo_controle)
	atualizar_modo_controle(GameManager.modo_mobile)

func _process(_delta: float) -> void:

	if player == null or input_manager == null:
		return

	# Não envia direções se o player estiver no meio da animação do item
	if player.item_controller and player.item_controller.usando_item:
		input_manager.limpar_direcao_mobile()
	else:
		if joystick_movimento and joystick_movimento.output != Vector2.ZERO:
			# Movimentação via Joystick Touch
			input_manager.definir_direcao_mobile(joystick_movimento.output)
		else:
			# Fallback para WASD / Setas durante testes no PC
			var direcao_teclado = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			input_manager.definir_direcao_mobile(direcao_teclado)

	atualizar_chave(GameManager.player_tem_chave)
	atualizar_dinamite(GameManager.player_dinamite)


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
		if valor:
			texto_upgrade.move_to_front()

	if btn_upgrade:
		btn_upgrade.visible = valor
		if valor:
			btn_upgrade.move_to_front()


func ocultar_upgrade() -> void:
	if texto_upgrade:
		texto_upgrade.visible = false
	if btn_upgrade:
		btn_upgrade.visible = false

func atualizar_modo_controle(mobile: bool) -> void:

	visible = mobile

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

	if get_viewport().gui_get_focus_owner():
		get_viewport().gui_get_focus_owner().release_focus()

	player.item_controller.usar_dinamite()


func _on_btn_ataque_pressed() -> void:
	if player == null:
		return
	if player.is_attack:
		return
	player.atacar()


func _on_button_pressed() -> void:
	UIManager.abrir_pause()
