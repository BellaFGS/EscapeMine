extends CharacterBody2D

@onready var anim = get_node_or_null("Animator")
@onready var texture = get_node_or_null("Texture")
@onready var barra_vida = get_node_or_null("BarraVida")

@export var speed = 100
@export var vida_max = 5
@export var vida = 5
@export var forca = 1

var ultima_direcao = "down"
var esta_morto = false
var is_attack = false
var tomando_dano = false
var knockback_velocity = Vector2.ZERO

func _ready():
	vida = vida_max
	atualizar_barra_vida()
	

func mover(direcao):
	if esta_morto:
		return
	
	if tomando_dano:
		velocity = knockback_velocity
		move_and_slide()
		
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.2)
		
		if knockback_velocity.length() < 10:
			tomando_dano = false
		
		return
	
	velocity = direcao * speed
	move_and_slide()

	atualizar_animacao(direcao)

func atualizar_animacao(direcao):
	if anim == null or is_attack:
		return
	if direcao == Vector2.ZERO:
		anim.play("idle_" + ultima_direcao)
		return

	if abs(direcao.x) > abs(direcao.y):
		ultima_direcao = "right" if direcao.x > 0 else "left"
	else:
		ultima_direcao = "down" if direcao.y > 0 else "up"
	
	anim.play("walk_" + ultima_direcao)

func atacar():
	if esta_morto or is_attack:
		return
	
	is_attack = true
	var hitbox = $hitBox
	hitbox.forca = forca
	hitbox.dono = self
	
	anim.play("attack_" + ultima_direcao)

func receber_dano(valor, origem: Vector2):
	if esta_morto:
		return
		

	vida -= valor
	emit_signal("vida_alterada", vida)
	atualizar_barra_vida()
	tomando_dano = true
	
	var direcao = (global_position - origem).normalized()
	knockback_velocity = direcao * 900
	
	flash_dano()
	
	if vida <= 0:
		morrer()

func morrer():
	if esta_morto:
		return
	esta_morto = true
	call_deferred("_morrer_impl")

func _morrer_impl():
	queue_free()

func flash_dano():
	if texture:
		texture.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	if texture:
		texture.modulate = Color(1, 1, 1)

func atualizar_barra_vida():
	if barra_vida:
		barra_vida.value = vida
		barra_vida.max_value = vida_max
		
		if vida < vida_max:
			barra_vida.visible = true
		else:
			barra_vida.visible = false

func _on_Animator_animation_finished():
	if anim.animation.begins_with("attack"):
		is_attack = false
		anim.play("idle_" + ultima_direcao)
