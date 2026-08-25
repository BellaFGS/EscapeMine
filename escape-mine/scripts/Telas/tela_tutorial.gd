extends CanvasLayer

func _on_btn_tutorial_2_pressed() -> void:
	AudioManager.tocar_sfx("click")
	GameFacade.abrir_tutorial_2()


func _on_button_pressed() -> void:
	AudioManager.tocar_sfx("click")
	GameFacade.voltar_menu()
