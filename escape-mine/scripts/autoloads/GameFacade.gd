extends Node
# Uma classe FACADE PODE frequentemente SER TRANSFORMADA em uma singleton 
# já que um único objeto fachada é suficiente na maioria dos casos.

# =========================
# JOGO
# =========================

func iniciar_jogo():
	GameManager.resetar()
	get_tree().paused = false
	AudioManager.tocar_musica("menu")
	SceneManager.trocar_cena("main")

func abrir_intro():
	SceneManager.trocar_cena("intro")
	
func voltar_menu():
	SceneManager.trocar_cena("inicial")

func reiniciar_jogo():
	SceneManager.trocar_cena("main")

func abrir_sala(destino: String):

	match destino:

		"sala_2":
			SceneManager.trocar_cena("sala_2")

		"sala_3":
			SceneManager.trocar_cena("sala_3")
			
		"score":
			SceneManager.trocar_cena("score")

		_:
			push_error("GameFacade: destino inválido: " + destino)


# =========================
# TELAS
# =========================

func abrir_pause():
	SceneManager.trocar_cena("pause")

func abrir_config():
	SceneManager.trocar_cena("config")

#TELAS DE TUTORIAIS
func abrir_tutorial_1():
	SceneManager.trocar_cena("tutorial_1")
func abrir_tutorial_2():
	SceneManager.trocar_cena("tutorial_2")
func abrir_tutorial_3():
	SceneManager.trocar_cena("tutorial_3")


func abrir_upgrade():
	UIManager.abrir_upgrade()

func abrir_tutorial2():
	SceneManager.abrir_tutorial2("tutorial2")


func fechar_upgrade():
	UIManager.fechar_upgrade()


# =========================
# FINAIS
# =========================

func game_over():
	SceneManager.trocar_cena("morte")


func vitoria():
	SceneManager.trocar_cena("vitoria")
