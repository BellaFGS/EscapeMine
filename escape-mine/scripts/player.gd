extends "res://scripts/Character.gd"

#signal vida_alterada(valor)
signal forca_alterado(valor)
signal xp_alterado(valor)
signal nivel_up(nivel)
signal dinamite_up(dinamite)

var xp: int = 0
var nivel: int = 1
var limite: int = 10
var dinamite: int = 0

var regen_intervalo := 0.5 # tempo pra ganhar +1 vida
var delay_regen := 2.0 # espera 2s sem tomar dano

var cena_dinamite = preload("res://scenes/items/dinamite_ativa.tscn")
@onready var inventario = $Inventario

func _ready():
	add_to_group("player")
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
	
	# ⏱️ tempo sem tomar dano
	tempo_sem_dano += delta

	# 💚 regeneração 
	if tempo_sem_dano >= delay_regen and vida < vida_max:
		regen_timer += delta
		
		if regen_timer >= regen_intervalo:
			regen_timer = 0.0
			vida += 1
			vida = min(vida, vida_max)
			
			emit_signal("vida_alterada", vida)
			atualizar_barra_vida()

	mover(direcao)

# ⭐ XP
func ganhar_xp(valor: int):
	xp += valor
	emit_signal("xp_alterado", xp)
	verificar_level_up()

func verificar_level_up():
	var limite = 10 + (nivel - 1) * 15
#	emit_signal("limite_up", limite)
	
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
	print("pegou dinamite")
	dinamite += 1
	emit_signal("dinamite_up", dinamite)
	item.aplicar(self)
	item.queue_free()

func adicionar_item(tipo: String):
	print("pegou dinamite")
	dinamite += 1
	emit_signal("dinamite_up", dinamite)

	inventario.adicionar_item(tipo, 1)

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
		d.global_position = global_position + Vector2(20, 0)
		print("usou dinamite")
		dinamite -= 1
		emit_signal("dinamite_up", dinamite)

func _on_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack"):
		is_attack = false
		anim.play("idle_" + ultima_direcao)

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		receber_dano(body.forca, body.global_position)

func _on_hurt_box_area_entered(area: Area2D) -> void:
	print("colidiu com:", area.name)
	
	if area.is_in_group("enemy"):
		receber_dano(area.get_parent().forca, area.global_position)
	
	elif area.is_in_group("trap"):
		receber_dano(50, area.global_position)
