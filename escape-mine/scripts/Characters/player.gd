extends "res://scripts/Character.gd"

signal forca_alterado(valor)
signal dinamite_up(dinamite)

var input_manager: PlayerInputManager
var item_controller: ItemUseController

var regen_intervalo := 0.5
var delay_regen := 2.0

var esta_morrendo := false

var efeitos = []
var tem_escudo := false

@onready var inventario = $Inventario
@onready var hurtBox = $hurtBox/Collision
@onready var collision = $Collision


func _ready():
	add_to_group("player")
	speed = 300
	input_manager = PlayerInputManager.new(self)
	item_controller = ItemUseController.new(self)
	GameManager.partida_resetada.connect(input_manager.resetar)
	GameManager.carregar_atributos_player(self)


	# CONEXÃO GARANTIDA DO SINAL DO ANIMATOR
	if anim:
		if not anim.animation_finished.is_connected(_on_animator_animation_finished):
			anim.animation_finished.connect(_on_animator_animation_finished)
			print("[LOG PLAYER] Sinal animation_finished conectado com sucesso.")
	else:
		print("[ERRO PLAYER] Nó Animator não foi encontrado!")

	GameManager.carregar_atributos_player(self)

	if GameManager.upgrade_pendente != "":
		aplicar_update(GameManager.upgrade_pendente)
		GameManager.upgrade_pendente = ""

	emit_signal("dinamite_up", inventario.quantidade_item("dinamite"))


func _physics_process(delta):
	if esta_morrendo or item_controller.usando_item:
		return

	var comandos := input_manager.obter_comandos()
	for comando in comandos:
		comando.executar()

	if Input.is_action_just_pressed("attack") and not is_attack:
		atacar()

	tempo_sem_dano += delta
	if tempo_sem_dano >= delay_regen and vida < vida_max:
		regen_timer += delta
		if regen_timer >= regen_intervalo:
			regen_timer = 0.0
			vida += 1
			vida = min(vida, vida_max)
			emit_signal("vida_alterada", vida)
			atualizar_barra_vida()

	for efeito in efeitos:
		efeito.atualizar(delta)


func usar_dinamite() -> void:
	if item_controller == null:
		return
	item_controller.usar_dinamite()


func _on_animator_animation_finished(anim_name: StringName):
	print("[LOG PLAYER] Animação finalizada: ", anim_name)

	if anim_name == "lucas_death":
		GameManager.finalizar_jogo("LOSE")
		return

	if anim_name.begins_with("attack"):
		is_attack = false
		anim.play("idle_" + ultima_direcao)
		return

	if anim_name == "use_dinamite":
		print("[LOG PLAYER] Fim da animação use_dinamite. Liberando controle do Player.")
		
		# 1. Libera a trava do item
		if item_controller:
			item_controller.usando_item = false

		# 2. Reseta velocidade física acumulada
		velocity = Vector2.ZERO
		
		# 3. Reseta o gerenciador de inputs
		if input_manager:
			input_manager.resetar()

		# 4. Força a animação Idle
		anim.play("idle_" + ultima_direcao)

		# 5. Força a atualização do movimento para destravar o move_and_slide()
		mover(Vector2.ZERO)
func ganhar_xp(valor: int):
	UpgradeSystem.ganhar_xp(valor)

func aplicar_update(tipo: String):
	match tipo:
		"vida":
			vida_max += 20
			vida = vida_max
			emit_signal("vida_alterada", vida)
		"forca":
			forca += 3
			emit_signal("forca_alterado", forca)

func pegar_item(item):
	AudioManager.tocar_sfx("item")
	item.aplicar(self)
	item.queue_free()

func adicionar_item(tipo: String):
	inventario.adicionar_item(tipo, 1)
	if tipo == "dinamite":
		emit_signal("dinamite_up", inventario.quantidade_item("dinamite"))

func morrer():
	if esta_morrendo:
		return
	esta_morrendo = true
	set_physics_process(false)
	AudioManager.tocar_sfx("morte")
	anim.play("lucas_death")

func _input(event):
	if event.is_action_pressed("usar_item"):
		usar_dinamite()

	if event.is_action_pressed("upgrade") and UpgradeSystem.upgrade_disponivel:
		GameFacade.abrir_upgrade()

func adicionar_efeito(efeito):
	efeitos.append(efeito)
	add_child(efeito)
	efeito.iniciar(self)

func _on_hurt_box_body_entered(body: Node2D):
	if not body.is_in_group("enemy"):
		return
	receber_dano(body.forca, body.global_position, body)
	hurtBox.set_deferred("disabled", true)
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(hurtBox):
		hurtBox.set_deferred("disabled", false)

func _on_hurt_box_area_entered(area: Area2D):
	print("Colidiu com: ", area.name)
	if area.is_in_group("enemy"):
		receber_dano(area.forca, area.global_position, area.get("dono"))
	elif area.is_in_group("trap"):
		receber_dano(50, area.global_position)
