extends Control

func _ready():
	pass

func _on_forca_up_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")

	UpgradeSystem.aplicar_upgrade(
		player,
		"forca"
	)
	UIManager.fechar_upgrade()


func _on_vida_up_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")

	UpgradeSystem.aplicar_upgrade(
		player,
		"vida"
	)
	UIManager.fechar_upgrade()
