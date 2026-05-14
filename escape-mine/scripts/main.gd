extends Node2D

func _ready():
	GameManager.resetar()
	MusicManager.play_music(preload("res://sounds/sons_gameplay/musica_de_fundo.mp3"))
	UIManager.registrar_telas($Tela_Pause,$Tela_Config)
