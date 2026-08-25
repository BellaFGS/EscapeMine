extends Control


@onready var barra_vida = $BarraVidaTextura
@onready var barra_dano = $BarraDanoTextura
@onready var barra_xp = $BarraXp/BarraXpTextura

@onready var texto_vida = $TextoVida
@onready var texto_força = $TextoForca
@onready var texto_xp = $BarraXp/TextoXp
@onready var texto_nivel = $Nivel
@onready var texto_pontos: Label = $Pontos

@onready var texto_dinamite = $Dinamite
@onready var chave = $ItemChave

@onready var texto_upgrade: Label = $UpgradeContainer/TextoUpgrade


var player


func _process(_delta):

	# Mostra ou esconde a chave
	chave.visible = GameManager.player_tem_chave


func _ready():

	ScoreManager.pontuacao_alterada.connect(atualizar_pontuacao)
	atualizar_pontuacao(ScoreManager.pontuacao_atual)

	player = get_tree().get_first_node_in_group("player")

	await get_tree().process_frame

	if player == null:
		print("Player não encontrado")
		return

	# ============================================================
	# PLAYER
	# ============================================================

	player.vida_alterada.connect(atualizar_vida)
	player.forca_alterado.connect(forca_alterado)
	player.dinamite_up.connect(dinamite)


	# ============================================================
	# UPGRADE SYSTEM
	# ============================================================

	UpgradeSystem.xp_alterado.connect(xp_alterado)
	UpgradeSystem.nivel_up.connect(nivel_up)
	UpgradeSystem.liberar_upgrade.connect(mostrar_upgrade)


	# ============================================================
	# VALORES INICIAIS
	# ============================================================

	atualizar_vida(player.vida)
	forca_alterado(player.forca)
	dinamite(player.dinamite)

	xp_alterado(UpgradeSystem.xp)
	nivel_up(UpgradeSystem.nivel)

	texto_upgrade.visible = false


# ============================================================
# UPGRADE
# ============================================================

func mostrar_upgrade(valor):

	texto_upgrade.visible = valor


# ============================================================
# VIDA
# ============================================================

func atualizar_vida(valor):

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

	texto_força.text = str(player.forca)


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

func atualizar_pontuacao(valor: int) -> void:

	texto_pontos.text = "SCORE  %07d" % valor
