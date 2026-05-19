extends Node

# =========================
# JOGO
# =========================

func iniciar_jogo():
	AudioManager.tocar_musica("menu")
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

func abrir_upgrade():
	UIManager.abrir_upgrade()

func fechar_upgrade():
	UIManager.fechar_upgrade()


# =========================
# FINAIS
# =========================

func game_over():
	SceneManager.trocar_cena("morte")


func vitoria():
	SceneManager.trocar_cena("vitoria")
