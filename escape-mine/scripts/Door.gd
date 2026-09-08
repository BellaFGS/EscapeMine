extends Area2D

@onready var anim = $Animation

@export var destino: String = ""

const CENA_CUTSCENE := preload("res://telas/CutCene.tscn")
const BONUS_BOSS := 10000

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

		# =====================================================
		# ENTRADA NA SALA DO BOSS
		# =====================================================
		# A cutscene é exibida antes de entrar na sala do boss.
		if destino == "sala_3":
			await _reproduzir_cutscene()

		# =====================================================
		# PORTA DE SAÍDA / VITÓRIA
		# =====================================================
		# Quando o player passa pela porta que leva ao score,
		# significa que ele derrotou o boss e conseguiu escapar.
		if destino == "score":

			# Adiciona o bônus de 10.000 pontos pelo boss.
			ScoreManager.adicionar_bonus_boss(BONUS_BOSS)

			# Define o resultado como vitória.
			# Isso faz a tela de score mostrar "MISSÃO CUMPRIDA!"
			# em vez de "A MINA VENCEU DESTA VEZ".
			ScoreManager.finalizar_partida("WIN")

		# GameFacade fica responsável pelo redirecionamento.
		GameFacade.abrir_sala(destino)

	else:

		# Player ainda não possui a chave.
		anim.play("mexer")

		await anim.animation_finished


func _reproduzir_cutscene() -> void:

	var cutscene := CENA_CUTSCENE.instantiate()

	get_tree().root.add_child(cutscene)

	var video := cutscene.get_node_or_null(
		"Fundo/VideoStreamPlayer"
	) as VideoStreamPlayer

	if video == null or video.stream == null:
		push_error(
			"Door: a cutscene ou o arquivo de vídeo não foi encontrado."
		)

		cutscene.queue_free()
		return

	AudioManager.parar_musica()

	get_tree().paused = true

	video.play()

	await video.finished

	get_tree().paused = false

	if is_instance_valid(cutscene):
		cutscene.queue_free()
