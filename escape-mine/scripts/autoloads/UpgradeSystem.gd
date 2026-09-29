extends Node

signal xp_alterado(valor)
signal nivel_up(nivel)
signal liberar_upgrade(valor)

var xp: int = 0
var nivel: int = 1
var limite: int = 10

var upgrade_disponivel := false


# ============================================================
# XP
# ============================================================

func ganhar_xp(valor: int):

	if valor <= 0:
		return

	xp += valor

	emit_signal("xp_alterado", xp)

	verificar_level_up()


# ============================================================
# LEVEL UP
# ============================================================

func verificar_level_up():

	calcular_limite()

	if xp >= limite and not upgrade_disponivel:
		upgrade_disponivel = true

		emit_signal("liberar_upgrade", true)


# ============================================================
# APLICAR UPGRADE
# ============================================================

func aplicar_upgrade(player, tipo: String):
	if not upgrade_disponivel:
		return

	var custo_do_nivel := limite

	match tipo:

		"vida":

			player.vida_max += 20
			player.vida = player.vida_max

			player.emit_signal(
				"vida_alterada",
				player.vida
			)


		"forca":

			player.forca += 3

			player.emit_signal(
				"forca_alterado",
				player.forca
			)


	# ========================================================
	# SALVA OS ATRIBUTOS ATUALIZADOS
	# ========================================================

	GameManager.salvar_atributos_player(player)


	# ========================================================
	# LEVEL
	# ========================================================

	nivel += 1

	calcular_limite()

	emit_signal("nivel_up", nivel)


	# ========================================================
	# CONSOME SOMENTE O XP NECESSÁRIO PARA ESTE NÍVEL
	# ========================================================

	xp -= custo_do_nivel
	upgrade_disponivel = xp >= limite

	emit_signal("xp_alterado", xp)
	emit_signal("liberar_upgrade", upgrade_disponivel)


# ============================================================
# RESET
# ============================================================

func resetar():

	xp = 0
	nivel = 1

	calcular_limite()

	upgrade_disponivel = false

	emit_signal("xp_alterado", xp)
	emit_signal("nivel_up", nivel)
	emit_signal("liberar_upgrade", false)


# ============================================================
# LIMITE DE XP
# ============================================================

func calcular_limite():

	limite = 10 + (nivel - 1) * 15
