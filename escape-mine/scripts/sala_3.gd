extends Node2D

@onready var camera_sala = $Camera2D


func _ready():

	# Desativa a câmera do Player
	var player = get_tree().get_first_node_in_group("player")

	if player:
		var camera_player = player.get_node_or_null("Camera2D")

		if camera_player:
			camera_player.enabled = false

	# Ativa a câmera da Sala 3
	camera_sala.enabled = true
	camera_sala.make_current()

	AudioManager.tocar_musica("main")

	UIManager.registrar_telas(
		$Tela_Pause,
		$Tela_Config,
		$Tela_upgrade
	)
