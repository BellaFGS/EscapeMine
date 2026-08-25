extends Area2D

@onready var anim = $Animation

@export var destino: String = ""

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

		# GameFacade fica responsável pelo redirecionamento
		GameFacade.abrir_sala(destino)

	else:

		anim.play("mexer")

		await anim.animation_finished
