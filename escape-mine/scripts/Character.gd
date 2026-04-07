extends CharacterBody2D

@onready var anim = get_node_or_null("Animator")
@onready var texture = get_node_or_null("Texture")

@export var speed = 100
@export var vida = 5
@export var dano = 1

var ultima_direcao = "down"
var esta_morto = false
var is_attack = false
var tomando_dano = false
var knockback_velocity = Vector2.ZERO

func mover(direcao):
	if esta_morto:
		return
	
	if tomando_dano:
		velocity = knockback_velocity
		move_and_slide()
		
		# desacelera knockback
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.2)
		
		# para quando estiver fraco
		if knockback_velocity.length() < 10:
			tomando_dano = false
		
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

# ⚔️ ATAQUE 
func atacar():
	if esta_morto or is_attack:
		return
	
	is_attack = true
	var hitbox = $hitBox
	hitbox.dano = dano
	hitbox.dono = self
	
	anim.play("attack_" + ultima_direcao)

# ❤️ DANO
func receber_dano(valor, origem: Vector2):
	if esta_morto:
		return
	
	vida -= valor
	#emit_signal("vida_alterada", vida)
	
	tomando_dano = true
	
	# 💥 KNOCKBACK
	var direcao = (global_position - origem).normalized()
	var forca = 900
	knockback_velocity = direcao * forca
	
	# ❤️ FLASH (separado)
	flash_dano()
	
	if vida <= 0:
		morrer()
# 💀 MORTE
func morrer():
	esta_morto = true
	velocity = Vector2.ZERO
	
	#anim.play("death")
	
	#await anim.animation_finished
	queue_free()

func flash_dano():
	if texture:
		texture.modulate = Color(1, 0, 0)
	
	await get_tree().create_timer(0.2).timeout
	
	if texture:
		texture.modulate = Color(1, 1, 1)

func _on_Animator_animation_finished():
	if anim.animation.begins_with("attack"):
		is_attack = false
		anim.play("idle_" + ultima_direcao)
		
