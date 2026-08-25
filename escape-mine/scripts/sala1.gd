extends Node2D

func _ready():
	GameManager.resetar()
	AudioManager.tocar_musica("main")
	UIManager.registrar_telas(
	$Tela_Pause,
	$Tela_Config,
	$Tela_upgrade
)
