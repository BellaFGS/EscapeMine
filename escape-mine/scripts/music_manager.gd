extends Node

var musica_fundo: AudioStreamPlayer

func _ready():
	musica_fundo = AudioStreamPlayer.new()
	add_child(musica_fundo)

func play_music(stream: AudioStream):
	if musica_fundo.stream == stream and musica_fundo.playing:
		return
	
	musica_fundo.stream = stream
	musica_fundo.play()

func stop_music():
	musica_fundo.stop()
