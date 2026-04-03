extends "res://scripts/Character.gd"


func _ready():
	speed = 200

func _physics_process(delta):
	var direcao = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	mover(direcao)

func morrer():
	GameManager.finalizar_jogo("LOSE")

func pegar_item(item):
	item.aplicar(self)
	item.queue_free()
