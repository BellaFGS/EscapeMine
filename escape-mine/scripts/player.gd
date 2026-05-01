extends "res://scripts/Character.gd"

#signal vida_alterada(valor)
signal forca_alterado(valor)
signal xp_alterado(valor)
signal nivel_up(nivel)

var xp: int = 0
var nivel: int = 1
var limite: int = 10
var cena_dinamite = preload("res://scenes/items/dinamite_ativa.tscn")
@onready var inventario = $Inventario

func _ready():
	speed = 300
	vida_max = 100
	vida = vida_max
	forca = 1

func _physics_process(delta):
	var direcao = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	if Input.is_action_just_pressed("attack") and not is_attack:
		atacar()

	mover(direcao)

# ⭐ XP
func ganhar_xp(valor: int):
	xp += valor
	emit_signal("xp_alterado", xp)
	verificar_level_up()

func verificar_level_up():
	var limite = 10 + (nivel - 1) * 15
	emit_signal("limite_up", limite)
	
	if xp >= limite:
		xp -= limite
		nivel += 1
		emit_signal("nivel_up", nivel)

# 🔼 UPGRADE
func aplicar_update(tipo: String):
	match tipo:
		"vida":
			vida_max += 20
			vida = vida_max
			emit_signal("vida_alterada", vida)
		
		"forca":
			forca += 3
			emit_signal("forca_alterado", forca)

# 🎒 ITEM
func pegar_item(item):
	item.aplicar(self)
	item.queue_free()

# 👉 usado pelos itens
func adicionar_item(tipo: String):
	inventario.adicionar_item(tipo)

func usar_item(tipo: String):
	return inventario.usar_item(tipo)

func morrer():
	GameManager.finalizar_jogo("LOSE")

func _input(event):
	if event.is_action_pressed("usar_item"): # tecla E
		usar_dinamite()

func usar_dinamite():
	if inventario.usar_item("dinamite"):
		var d = cena_dinamite.instantiate()
		get_parent().add_child(d)
		d.global_position = global_position + Vector2(20, 0) # joga pra frente

func _on_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack"):
		is_attack = false
		anim.play("idle_" + ultima_direcao)

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		receber_dano(body.forca, body.global_position)
