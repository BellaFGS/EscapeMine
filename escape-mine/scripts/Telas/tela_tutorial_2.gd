extends CanvasLayer

func _on_btn_para_tela_3_pressed() -> void:
	AudioManager.tocar_sfx("click")
	GameFacade.abrir_tutorial_3()


func _on_btn_tutorial_pressed() -> void:
	AudioManager.tocar_sfx("click")
	GameFacade.abrir_tutorial_1()
