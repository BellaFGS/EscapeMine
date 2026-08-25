extends Area2D

@onready var anim = $Animation

@export var destino: String = ""

const CENA_CUTSCENE := preload("res://telas/CutCene.tscn")

var entrando := false


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):

	if entrando:
		return

	if not body.is_in_group("player"):
		return

	if GameManager.player_tem_chave:

		entrando = true

		AudioManager.tocar_sfx("doorOpen")

		anim.play("abrir")

		await anim.animation_finished

		# A falsa vitória é exibida antes de entrar na sala do boss.
		if destino == "sala_3":
			await _reproduzir_cutscene()

		# GameFacade fica responsável pelo redirecionamento.
		GameFacade.abrir_sala(destino)

	else:

		anim.play("mexer")

		await anim.animation_finished



func _reproduzir_cutscene() -> void:
	var cutscene := CENA_CUTSCENE.instantiate()
	get_tree().root.add_child(cutscene)

	var video := cutscene.get_node_or_null("Fundo/VideoStreamPlayer") as VideoStreamPlayer
	if video == null or video.stream == null:
		push_error("Door: a cutscene ou o arquivo de vídeo não foi encontrado.")
		cutscene.queue_free()
		return

	AudioManager.parar_musica()
	get_tree().paused = true
	video.play()
	await video.finished
	get_tree().paused = false

	if is_instance_valid(cutscene):
		cutscene.queue_free()
