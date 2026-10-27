extends Node2D

@onready var camera_sala: Camera2D = $Camera2D

var player: Node2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	GameManager.resetar_chave()
	if player:
		BossCheckpointManager.preparar_sala(player)

	if player:
		var camera_player = player.get_node_or_null("Camera2D")

		if camera_player:
			camera_player.enabled = false

		camera_sala.global_position = player.global_position

	camera_sala.enabled = true
	camera_sala.zoom = Vector2(1.5, 1.5)
	camera_sala.position_smoothing_enabled = false
	camera_sala.make_current()

	AudioManager.tocar_musica("main")

	UIManager.registrar_telas(
		$Tela_Pause,
		$Tela_Config,
		$Tela_upgrade
	)


func _process(_delta: float) -> void:
	if is_instance_valid(player):
		camera_sala.global_position = player.global_position
