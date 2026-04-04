extends CharacterBody2D

@onready var anim = get_node_or_null("Animator")
var vida = 100
var dano = 10
var speed = 100

var ultima_direcao = "down"
var esta_morto = false
var is_attack = false

func mover(direcao):
	if esta_morto:
		return
	
	velocity = direcao * speed
	move_and_slide()

	atualizar_animacao(direcao)

# 🔥 CONTROLE DE ANIMAÇÃO
func atualizar_animacao(direcao):
	if anim == null or is_attack:
		return
	if direcao == Vector2.ZERO:
		anim.play("idle_" + ultima_direcao)
		return
	# Define direção
	if abs(direcao.x) > abs(direcao.y):
		if direcao.x > 0:
			ultima_direcao = "right"
		else:
			ultima_direcao = "left"
	else:
		if direcao.y > 0:
			ultima_direcao = "down"
		else:
			ultima_direcao = "up"
	
	anim.play("walk_" + ultima_direcao)

# ⚔️ ATAQUE (você chama isso quando quiser)
func atacar():
	if esta_morto or is_attack:
		return
	
	is_attack = true
	anim.play("attack_" + ultima_direcao)

# ❤️ DANO
func receber_dano(valor):
	if esta_morto:
		return
	
	vida -= valor
	
	if vida <= 0:
		morrer()

# 💀 MORTE
func morrer():
	esta_morto = true
	velocity = Vector2.ZERO
	
	#anim.play("death")
	
	#await anim.animation_finished
	queue_free()

func _on_Animator_animation_finished():
	if anim.animation.begins_with("attack"):
		is_attack = false
		anim.play("idle_" + ultima_direcao)
