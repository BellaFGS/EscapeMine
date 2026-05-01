extends Node

@onready var musica_fundo: AudioStreamPlayer = $musica_fundo

func play_music(stream: AudioStream):
	# evita reiniciar a mesma música
	if musica_fundo.stream == stream and musica_fundo.playing:
		return
	
	musica_fundo.stream = stream
	musica_fundo.play()

func stop_music():
	musica_fundo.stop()
