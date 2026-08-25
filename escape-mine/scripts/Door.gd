extends Area2D

@onready var anim = $Animation

@export_file("*.tscn")
var proxima_sala: String = "res://telas/Sala2.tscn"

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

		if proxima_sala.is_empty() or not ResourceLoader.exists(proxima_sala):
			push_error("Porta: cena de destino inválida: " + proxima_sala)
			entrando = false
			return

		var erro := get_tree().change_scene_to_file(proxima_sala)
		if erro != OK:
			push_error("Porta: não foi possível abrir: " + proxima_sala)
			entrando = false

	else:

		anim.play("mexer")
		await anim.animation_finished
