extends Node2D

func _ready():
	await get_tree().process_frame

	var video = $Control/VideoStreamPlayer
	var tela = get_viewport().get_visible_rect().size

	video.anchor_left = 0
	video.anchor_top = 0
	video.anchor_right = 0
	video.anchor_bottom = 0

	video.position = Vector2(
		(tela.x - video.size.x) / 2,
		(tela.y - video.size.y) / 2
	)
	
func _process(_delta):
	var video = $Control/VideoStreamPlayer
	var tela = get_viewport().get_visible_rect().size

	video.position = Vector2(
		(tela.x - video.size.x) / 2,
		(tela.y - video.size.y) / 2
	)

func _on_video_stream_player_finished() -> void:
	GameFacade.voltar_menu()


func _on_btn_skip_pressed() -> void:
	GameFacade.voltar_menu()
