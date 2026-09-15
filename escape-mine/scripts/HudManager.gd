extends Control


@onready var barra_vida = $Container/containerMargin/HSplitContainer/BoxContainerStatus/VSplitContainer/BoxContainerVida/HSplitContainer/BarraVidaTextura
@onready var barra_dano = $Container/containerMargin/HSplitContainer/BoxContainerStatus/VSplitContainer/BoxContainerDano/HSplitContainer/BarraDanoTextura
@onready var barra_xp = $Container/containerMargin/BoxContainerBarraXp/BarraXp/BarraXpTextura


@onready var texto_vida = $Container/containerMargin/HSplitContainer/BoxContainerStatus/VSplitContainer/BoxContainerVida/HSplitContainer/BarraVidaTextura/TextoVida
@onready var texto_força = $Container/containerMargin/HSplitContainer/BoxContainerStatus/VSplitContainer/BoxContainerDano/HSplitContainer/BarraDanoTextura/TextoForca
@onready var texto_xp = $Container/containerMargin/BoxContainerBarraXp/BarraXp/TextoXp
@onready var texto_nivel = $Container/containerMargin/HSplitContainer/BoxContainerNivel/PanelNivel/Nivel
@onready var texto_pontos: Label = $Container/containerMargin/HSplitContainer/BoxContainerPontos/Pontos

@onready var texto_dinamite = $Container/containerMargin/MarginContainer/BoxContainerAtributos/VSplitContainerAtributos/BoxContainerItemDinamite/PanelItemDinamite/MarginContainer/HSplitContainer/Dinamite
@onready var chave = $Container/containerMargin/MarginContainer/BoxContainerAtributos/VSplitContainerAtributos/BoxContainerItemChave

@onready var texto_upgrade: Label = $Container/containerMargin/BoxContainerUpgrade/TextoUpgrade


var player


func _ready():
	
	

	# ============================================================
	# SCORE
	# ============================================================

	ScoreManager.pontuacao_alterada.connect(
		atualizar_pontuacao
	)

	atualizar_pontuacao(
		ScoreManager.pontuacao_atual
	)


	# ============================================================
	# PLAYER
	# ============================================================

	await get_tree().process_frame

	player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("Player não encontrado")
		return


	player.vida_alterada.connect(
		atualizar_vida
	)

	player.forca_alterado.connect(
		forca_alterado
	)

	player.dinamite_up.connect(
		dinamite
	)


	# ============================================================
	# UPGRADE SYSTEM
	# ============================================================

	UpgradeSystem.xp_alterado.connect(
		xp_alterado
	)

	UpgradeSystem.nivel_up.connect(
		nivel_up
	)

	UpgradeSystem.liberar_upgrade.connect(
		mostrar_upgrade
	)


	# ============================================================
	# VALORES INICIAIS
	# ============================================================

	atualizar_vida(
		player.vida
	)

	forca_alterado(
		player.forca
	)

	# Agora a dinamite vem do GameManager
	dinamite(
		GameManager.player_dinamite
	)

	xp_alterado(
		UpgradeSystem.xp
	)

	nivel_up(
		UpgradeSystem.nivel
	)


	texto_upgrade.visible = false


# ============================================================
# PROCESSO
# ============================================================

func _process(_delta):

	# A chave é persistente no GameManager
	chave.visible = GameManager.player_tem_chave

	# Mantém a dinamite sincronizada
	# mesmo que o Player seja recriado
	dinamite(
		GameManager.player_dinamite
	)


# ============================================================
# UPGRADE
# ============================================================

func mostrar_upgrade(valor):

	texto_upgrade.visible = valor
	if valor:
		# Se TextoUpgrade for filho direto da HUD, basta dar move_to_front nele
		texto_upgrade.move_to_front()
		
		# Se ele estiver dentro de um BoxContainerUpgrade, mova o container pai para frente:
		# $Container/containerMargin/BoxContainerUpgrade.move_to_front()

# ============================================================
# VIDA
# ============================================================

func atualizar_vida(valor):

	if player == null:
		return

	barra_vida.max_value = player.vida_max

	barra_vida.value = valor

	texto_vida.text = (
		str(player.vida)
		+ "/"
		+ str(player.vida_max)
	)


# ============================================================
# FORÇA
# ============================================================

func forca_alterado(valor):

	barra_dano.value = valor

	if player:

		texto_força.text = str(
			player.forca
		)


# ============================================================
# XP
# ============================================================

func xp_alterado(valor):

	barra_xp.value = valor

	barra_xp.max_value = UpgradeSystem.limite

	texto_xp.text = (
		str(UpgradeSystem.xp)
		+ "/"
		+ str(UpgradeSystem.limite)
	)


# ============================================================
# NÍVEL
# ============================================================

func nivel_up(valor):

	texto_nivel.text = str(valor)


# ============================================================
# DINAMITE
# ============================================================

func dinamite(valor):

	texto_dinamite.text = str(valor)


# ============================================================
# PONTUAÇÃO
# ============================================================

func atualizar_pontuacao(valor: int):

	texto_pontos.text = "SCORE  %07d" % valor
