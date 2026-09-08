extends "res://scripts/Character.gd"


signal forca_alterado(valor)
signal dinamite_up(dinamite)


var regen_intervalo := 0.5
var delay_regen := 2.0

var esta_morrendo := false
var usando_dinamite := false

var efeitos = []
var tem_escudo := false


var cena_dinamite = preload(
	"res://scenes/items/dinamite_ativa.tscn"
)


@onready var inventario = $Inventario
@onready var hurtBox = $hurtBox/Collision
@onready var collision = $Collision


func _ready():

	add_to_group("player")

	speed = 300

	# Carrega atributos persistentes.
	GameManager.carregar_atributos_player(self)

	if GameManager.upgrade_pendente != "":

		aplicar_update(
			GameManager.upgrade_pendente
		)

		GameManager.upgrade_pendente = ""

	# Atualiza o HUD com a quantidade persistente.
	emit_signal(
		"dinamite_up",
		inventario.quantidade_item("dinamite")
	)


# ============================================================
# FÍSICA
# ============================================================

func _physics_process(delta):

	if usando_dinamite or esta_morrendo:
		return

	var direcao = Vector2(
		Input.get_action_strength("right")
		- Input.get_action_strength("left"),

		Input.get_action_strength("down")
		- Input.get_action_strength("up")
	).normalized()


	# ATAQUE

	if (
		Input.is_action_just_pressed("attack")
		and not is_attack
	):

		atacar()


	# REGENERAÇÃO

	tempo_sem_dano += delta

	if (
		tempo_sem_dano >= delay_regen
		and vida < vida_max
	):

		regen_timer += delta

		if regen_timer >= regen_intervalo:

			regen_timer = 0.0

			vida += 1

			vida = min(
				vida,
				vida_max
			)

			emit_signal(
				"vida_alterada",
				vida
			)

			atualizar_barra_vida()


	# EFEITOS

	for efeito in efeitos:

		efeito.atualizar(delta)


	mover(direcao)


# ============================================================
# XP
# ============================================================

func ganhar_xp(valor: int):

	UpgradeSystem.ganhar_xp(valor)


# ============================================================
# UPGRADE
# ============================================================

func aplicar_update(tipo: String):

	match tipo:

		"vida":

			vida_max += 20
			vida = vida_max

			emit_signal(
				"vida_alterada",
				vida
			)


		"forca":

			forca += 3

			emit_signal(
				"forca_alterado",
				forca
			)


# ============================================================
# ITEM
# ============================================================

func pegar_item(item):

	AudioManager.tocar_sfx("item")

	item.aplicar(self)

	item.queue_free()


func adicionar_item(tipo: String):

	inventario.adicionar_item(
		tipo,
		1
	)

	if tipo == "dinamite":

		emit_signal(
			"dinamite_up",
			inventario.quantidade_item("dinamite")
		)


# ============================================================
# USAR DINAMITE
# ============================================================

func usar_dinamite():

	if usando_dinamite:
		return

	if not inventario.usar_item("dinamite"):
		return

	usando_dinamite = true

	anim.play(
		"use_dinamite"
	)

	var d = cena_dinamite.instantiate()

	get_parent().add_child(d)

	d.global_position = (
		global_position + Vector2(20, 0)
	)

	# Atualiza HUD com a quantidade REAL do inventário.
	emit_signal(
		"dinamite_up",
		inventario.quantidade_item("dinamite")
	)


# ============================================================
# MORTE
# ============================================================

func morrer():

	if esta_morrendo:
		return

	esta_morrendo = true

	set_physics_process(false)

	AudioManager.tocar_sfx(
		"morte"
	)

	anim.play(
		"lucas_death"
	)


# ============================================================
# INPUT
# ============================================================

func _input(event):

	if event.is_action_pressed("usar_item"):

		usar_dinamite()


	if (
		event.is_action_pressed("upgrade")
		and UpgradeSystem.upgrade_disponivel
	):

		GameFacade.abrir_upgrade()


# ============================================================
# EFEITOS
# ============================================================

func adicionar_efeito(efeito):

	efeitos.append(efeito)

	add_child(efeito)

	efeito.iniciar(self)


# ============================================================
# ANIMAÇÕES
# ============================================================

func _on_animator_animation_finished(
	anim_name: StringName
):

	if anim_name == "lucas_death":

		GameManager.finalizar_jogo(
			"LOSE"
		)

		return


	if anim_name == "use_dinamite":

		usando_dinamite = false

		anim.play(
			"idle_" + ultima_direcao
		)

		return


	if anim_name.begins_with("attack"):

		is_attack = false

		anim.play(
			"idle_" + ultima_direcao
		)


# ============================================================
# COLISÃO COM INIMIGOS
# ============================================================

func _on_hurt_box_body_entered(body: Node2D):

	if not body.is_in_group("enemy"):
		return

	receber_dano(
		body.forca,
		body.global_position,
		body
	)

	hurtBox.set_deferred(
		"disabled",
		true
	)

	await get_tree().create_timer(
		0.5
	).timeout

	if is_instance_valid(hurtBox):

		hurtBox.set_deferred(
			"disabled",
			false
		)


# ============================================================
# COLISÃO COM ÁREAS
# ============================================================

func _on_hurt_box_area_entered(
	area: Area2D
):

	print(
		"Colidiu com: ",
		area.name
	)

	if area.is_in_group("enemy"):

		receber_dano(
			area.forca,
			area.global_position,
			area.get("dono")
		)

	elif area.is_in_group("trap"):

		receber_dano(
			50,
			area.global_position
		)
