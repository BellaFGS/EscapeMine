extends "res://scripts/Character.gd"

func _ready():
	speed = 200
	

func _physics_process(delta):
	var direcao = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	if Input.is_action_just_pressed("attack") and not is_attack:
		atacar()

	mover(direcao)

func morrer():
	GameManager.finalizar_jogo("LOSE")

func pegar_item(item):
	item.aplicar(self)
	item.queue_free()


func _on_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack"):
		is_attack = false
