extends CanvasLayer

const INICIO_RISADA_SEGUNDOS := 10.0

@onready var video: VideoStreamPlayer = $Fundo/VideoStreamPlayer
@onready var risada: AudioStreamPlayer = $BowserLaugh

var risada_iniciada := false


func _process(_delta: float) -> void:
	if risada_iniciada or not video.is_playing():
		return

	# Usa a posição real do vídeo para manter o áudio sincronizado.
	if video.stream_position >= INICIO_RISADA_SEGUNDOS:
		risada_iniciada = true
		risada.play()
