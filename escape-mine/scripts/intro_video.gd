extends Node2D


func _on_video_stream_player_finished() -> void:
	GameFacade.voltar_menu()


func _on_button_pressed() -> void:
	GameFacade.voltar_menu()
