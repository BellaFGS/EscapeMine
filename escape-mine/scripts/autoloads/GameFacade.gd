extends Node

# =========================
# JOGO
# =========================

func iniciar_jogo():
	AudioManager.parar_musica()
	SceneManager.trocar_cena("main")


func voltar_menu():
	SceneManager.trocar_cena("inicial")

func reiniciar_jogo():
	SceneManager.trocar_cena("main")


# =========================
# TELAS
# =========================

func abrir_pause():
	SceneManager.trocar_cena("pause")


func abrir_config():
	SceneManager.trocar_cena("config")

func abrir_tutorial2():
	SceneManager.abrir_tutorial2("tutorial2")

func abrir_level_up():
	SceneManager.trocar_cena("level_up")


# =========================
# FINAIS
# =========================

func game_over():
	SceneManager.trocar_cena("morte")


func vitoria():
	SceneManager.trocar_cena("vitoria")
