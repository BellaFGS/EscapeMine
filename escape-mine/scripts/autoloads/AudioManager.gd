extends Node

var player_musica
var player_sfx

func _ready():

	player_musica = AudioStreamPlayer.new()
	add_child(player_musica)

	player_sfx = AudioStreamPlayer.new()
	add_child(player_sfx)

func tocar_musica(audio):

	player_musica.stream = audio
	player_musica.play()

func parar_musica():
	player_musica.stop()

func tocar_sfx(audio):

	player_sfx.stream = audio
	player_sfx.play()
