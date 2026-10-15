extends Control


# ============================================================
# REFERÊNCIAS DE UI
# ============================================================

@onready var barra_vida = $Container/containerMargin/HSplitContainer/BoxContainerStatus/VSplitContainer/BoxContainerVida/HSplitContainer/BarraVidaTextura

@onready var barra_dano = $Container/containerMargin/HSplitContainer/BoxContainerStatus/VSplitContainer/BoxContainerDano/HSplitContainer/BarraDanoTextura

@onready var barra_xp = $Container/containerMargin/BoxContainerBarraXp/BarraXp/BarraXpTextura


@onready var texto_vida = $Container/containerMargin/HSplitContainer/BoxContainerStatus/VSplitContainer/BoxContainerVida/HSplitContainer/BarraVidaTextura/TextoVida

@onready var texto_forca = $Container/containerMargin/HSplitContainer/BoxContainerStatus/VSplitContainer/BoxContainerDano/HSplitContainer/BarraDanoTextura/TextoForca

@onready var texto_xp = $Container/containerMargin/BoxContainerBarraXp/BarraXp/TextoXp

@onready var texto_nivel = $Container/containerMargin/HSplitContainer/BoxContainerNivel/PanelNivel/Nivel

@onready var texto_pontos: Label = $Container/containerMargin/HSplitContainer/BoxContainerPontos/Pontos


@onready var texto_dinamite = $Container/containerMargin/MarginContainer/BoxContainerAtributos/VSplitContainerAtributos/BoxContainerItemDinamite/PanelItemDinamite/MarginContainer/HSplitContainer/Dinamite

@onready var chave = $Container/containerMargin/MarginContainer/BoxContainerAtributos/VSplitContainerAtributos/BoxContainerItemChave

@onready var texto_upgrade: Label = $Container/containerMargin/BoxContainerUpgrade/TextoUpgrade


# ============================================================
# VARIÁVEIS
# ============================================================

var player = null


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready() -> void:
	# O HUD acompanha o modo definido pelo GameManager.
	if not GameManager.modo_controle_alterado.is_connected(
		atualizar_modo_controle
	):
		GameManager.modo_controle_alterado.connect(
			atualizar_modo_controle
		)

	atualizar_modo_controle(GameManager.modo_mobile)

	# ========================================================
	# PONTUAÇÃO
	# ========================================================

	if not ScoreManager.pontuacao_alterada.is_connected(atualizar_pontuacao):
		ScoreManager.pontuacao_alterada.connect(atualizar_pontuacao)

	atualizar_pontuacao(ScoreManager.pontuacao_atual)


	# ========================================================
	# PLAYER
	# ========================================================

	await get_tree().process_frame

	player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("Player não encontrado no HUD")
		return

	if not player.vida_alterada.is_connected(atualizar_vida):
		player.vida_alterada.connect(atualizar_vida)

	if not player.forca_alterado.is_connected(forca_alterado):
		player.forca_alterado.connect(forca_alterado)

	if not player.dinamite_up.is_connected(dinamite):
		player.dinamite_up.connect(dinamite)


	# ========================================================
	# UPGRADE SYSTEM
	# ========================================================

	if not UpgradeSystem.xp_alterado.is_connected(xp_alterado):
		UpgradeSystem.xp_alterado.connect(xp_alterado)

	if not UpgradeSystem.nivel_up.is_connected(nivel_up):
		UpgradeSystem.nivel_up.connect(nivel_up)

	if not UpgradeSystem.liberar_upgrade.is_connected(mostrar_upgrade):
		UpgradeSystem.liberar_upgrade.connect(mostrar_upgrade)


	# ========================================================
	# VALORES INICIAIS
	# ========================================================

	atualizar_vida(player.vida)
	forca_alterado(player.forca)
	dinamite(GameManager.player_dinamite)

	xp_alterado(UpgradeSystem.xp)
	nivel_up(UpgradeSystem.nivel)

	mostrar_upgrade(UpgradeSystem.upgrade_disponivel)


# ============================================================
# PROCESSAMENTO
# ============================================================

func _process(_delta: float) -> void:
	if not visible:
		return

	chave.visible = GameManager.player_tem_chave

	dinamite(GameManager.player_dinamite)


# ============================================================
# MODO DE CONTROLE
# ============================================================

func atualizar_modo_controle(mobile: bool) -> void:
	visible = not mobile


# ============================================================
# UPGRADE
# ============================================================

func mostrar_upgrade(valor: bool) -> void:
	if texto_upgrade:
		texto_upgrade.visible = valor


# ============================================================
# VIDA
# ============================================================

func atualizar_vida(valor: int) -> void:
	if player == null:
		return

	if barra_vida:
		barra_vida.max_value = player.vida_max
		barra_vida.value = valor

	if texto_vida:
		texto_vida.text = str(valor) + "/" + str(player.vida_max)


# ============================================================
# FORÇA
# ============================================================

func forca_alterado(valor: int) -> void:
	if barra_dano:
		barra_dano.value = valor

	if texto_forca:
		texto_forca.text = str(valor)


# ============================================================
# XP
# ============================================================

func xp_alterado(valor: int) -> void:
	if barra_xp:
		barra_xp.max_value = UpgradeSystem.limite
		barra_xp.value = valor

	if texto_xp:
		texto_xp.text = str(UpgradeSystem.xp) + "/" + str(UpgradeSystem.limite)


# ============================================================
# NÍVEL
# ============================================================

func nivel_up(valor: int) -> void:
	if texto_nivel:
		texto_nivel.text = str(valor)


# ============================================================
# DINAMITE
# ============================================================

func dinamite(valor: int) -> void:
	if texto_dinamite:
		texto_dinamite.text = str(valor)


# ============================================================
# PONTUAÇÃO
# ============================================================

func atualizar_pontuacao(valor: int) -> void:
	if texto_pontos:
		texto_pontos.text = "SCORE  %07d" % valor
