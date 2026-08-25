extends CharacterBody2D

signal vida_alterada(valor)

@onready var anim = get_node_or_null("Animator")
@onready var texture = get_node_or_null("Texture")
@onready var barra_vida = get_node_or_null("BarraVida")
var cor_original: Color = Color(1, 1, 1)

@export var speed = 100
@export var vida_max = 5
@export var vida = 5
@export var forca = 1
@export var pontos_ao_morrer: int = 100

var ultima_direcao = "down"
var esta_morto = false
var is_attack = false
var tomando_dano = false
var knockback_velocity = Vector2.ZERO
var direcao_ataque = "down"
var tempo_sem_dano := 0.0
var regen_timer := 0.0
var ultimo_atacante = null

# --- Invencibilidade após tomar dano (i-frames) ---
@export var tempo_invencibilidade: float = 0.5
var invencivel = false

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

func set_cor(cor):
	cor_original = cor
	if is_instance_valid(texture):
		texture.modulate = cor

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

#func atacar():
	#if esta_morto or is_attack:
		#return
#
	#is_attack = true
#
	#var hitbox = $hitBox
	#hitbox.forca = forca
	#hitbox.dono = self
#
	#var mouse_dir = (get_global_mouse_position() - global_position).normalized()
#
	#if abs(mouse_dir.x) > abs(mouse_dir.y):
		#direcao_ataque = "right" if mouse_dir.x > 0 else "left"
	#else:
		#direcao_ataque = "down" if mouse_dir.y > 0 else "up"
#
	#anim.play("attack_" + direcao_ataque)

func atacar():
	if esta_morto or is_attack:
		return

	is_attack = true

	var hitbox = $hitBox
	hitbox.forca = forca
	hitbox.dono = self

	direcao_ataque = ultima_direcao

	if is_in_group("player"):
		AudioManager.tocar_sfx("causa_dano")

	anim.play("attack_" + direcao_ataque)

	# A hitbox precisa ser ligada e desligada manualmente, senão o golpe
	# nunca colide com nada (ela fica desabilitada por padrão na cena).
	# Ajuste os dois tempos abaixo para casar com o frame de impacto
	# e a duração da janela de dano da sua animação "attack_*".
	await get_tree().create_timer(0.15).timeout   # tempo até o "impacto" da animação

	if not is_instance_valid(self) or esta_morto:
		return

	hitbox.set_deferred("monitoring", true)
	hitbox.get_node("Collision").set_deferred("disabled", false)

	await get_tree().create_timer(0.15).timeout   # duração da janela de dano

	if not is_instance_valid(self):
		return

	hitbox.set_deferred("monitoring", false)
	hitbox.get_node("Collision").set_deferred("disabled", true)

func receber_dano(valor, origem: Vector2, atacante = null):

	tempo_sem_dano = 0.0
	regen_timer = 0.0

	if esta_morto:
		return

	if invencivel:
		return

	if EffectManager.bloquear_dano(self):
		return

	# 🧠 guarda quem causou o dano
	if atacante != null:
		ultimo_atacante = atacante

	vida -= valor

	emit_signal("vida_alterada", vida)

	atualizar_barra_vida()

	tomando_dano = true

	var direcao = (
		global_position - origem
	).normalized()

	knockback_velocity = direcao * 1200

	flash_dano()

	if is_in_group("player"):
		AudioManager.tocar_sfx("hit")


	# EFEITOS DECORATOR
	if is_in_group("player") and atacante:
		if atacante.is_in_group("veneno"):
			EffectManager.adicionar_efeito(
				self,
				VenenoDecorator.new()
			)

		if atacante.is_in_group("cegueira"):

			EffectManager.adicionar_efeito(
				self,
				CegueiraDecorator.new()
			)

	if vida <= 0:
		morrer()
		return

	_ativar_invencibilidade()


func _ativar_invencibilidade():
	invencivel = true
	await get_tree().create_timer(tempo_invencibilidade).timeout

	if is_instance_valid(self):
		invencivel = false


func morrer():
	if esta_morto:
		return
	esta_morto = true
	call_deferred("_morrer_impl")

func conceder_pontos() -> void:
	if ultimo_atacante and ultimo_atacante.is_in_group("player"):
		ScoreManager.adicionar_pontos(pontos_ao_morrer)

func _morrer_impl():
	queue_free()

func flash_dano():
	if not is_instance_valid(texture):
		return

	# Guarda uma referência local e valida novamente após o await, pois o
	# personagem pode morrer e liberar o Sprite2D durante o flash.
	var sprite: CanvasItem = texture
	var cor_hit = cor_original.lerp(Color(1, 0, 0), 0.7)
	sprite.modulate = cor_hit

	await get_tree().create_timer(0.2).timeout

	if is_instance_valid(sprite):
		sprite.modulate = cor_original

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
		
func _on_hurt_box_area_entered(area):
	print("COLIDIU COM:", area)
