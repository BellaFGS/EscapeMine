extends "res://scripts/Character.gd"

signal vida_alterada(valor)
signal dano_alterado(valor)

func _ready():
	speed = 300
	vida = 10
	dano = 1
	

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
	emit_signal("vida_alterada", vida)
	emit_signal("dano_alterado", dano)
	item.queue_free()


func _on_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack"):
		is_attack = false
		anim.play("idle_" + ultima_direcao)


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		receber_dano(body.dano, body.global_position)
