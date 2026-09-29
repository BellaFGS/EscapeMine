extends Node


class InventarioTeste:
	extends RefCounted

	func quantidade_item(_nome: String) -> int:
		return 0


class PlayerTeste:
	extends Node

	signal vida_alterada(valor)
	signal forca_alterado(valor)

	var vida_max := 100
	var vida := 100
	var forca := 1
	var inventario := InventarioTeste.new()


func _ready() -> void:
	var player := PlayerTeste.new()
	add_child(player)
	UpgradeSystem.resetar()

	UpgradeSystem.ganhar_xp(8)
	assert(UpgradeSystem.xp == 8)
	assert(not UpgradeSystem.upgrade_disponivel)

	UpgradeSystem.ganhar_xp(7)
	assert(UpgradeSystem.xp == 15)
	assert(UpgradeSystem.upgrade_disponivel)

	# XP coletado enquanto o upgrade está pendente também é guardado.
	UpgradeSystem.ganhar_xp(30)
	assert(UpgradeSystem.xp == 45)

	UpgradeSystem.aplicar_upgrade(player, "forca")
	assert(UpgradeSystem.nivel == 2)
	assert(UpgradeSystem.limite == 25)
	assert(UpgradeSystem.xp == 35)
	assert(UpgradeSystem.upgrade_disponivel)
	assert(player.forca == 4)

	UpgradeSystem.aplicar_upgrade(player, "vida")
	assert(UpgradeSystem.nivel == 3)
	assert(UpgradeSystem.limite == 40)
	assert(UpgradeSystem.xp == 10)
	assert(not UpgradeSystem.upgrade_disponivel)
	assert(player.vida_max == 120)

	UpgradeSystem.ganhar_xp(31)
	assert(UpgradeSystem.xp == 41)
	assert(UpgradeSystem.upgrade_disponivel)
	UpgradeSystem.aplicar_upgrade(player, "forca")
	assert(UpgradeSystem.nivel == 4)
	assert(UpgradeSystem.xp == 1)
	assert(not UpgradeSystem.upgrade_disponivel)

	UpgradeSystem.resetar()
	assert(UpgradeSystem.nivel == 1)
	assert(UpgradeSystem.limite == 10)
	assert(UpgradeSystem.xp == 0)
	assert(not UpgradeSystem.upgrade_disponivel)

	print("XP_OVERFLOW_OK")
	get_tree().quit()
