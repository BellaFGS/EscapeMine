extends CanvasLayer

func _on_btn_tutorial_2_pressed() -> void:
	GameFacade.abrir_tutorial_2()


func _on_button_pressed() -> void:
	GameFacade.voltar_menu()
