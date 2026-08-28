extends "res://scripts/Character.gd"

var player


func _ready():

	player = get_tree().get_first_node_in_group("player")

	pontos_ao_morrer = 200

	state_machine = EnemyStateMachine.new()
	state_machine.inicializar(self)


func _physics_process(delta):

	if esta_morto:
		return

	if state_machine:
		state_machine.atualizar(delta)
		state_machine.fisica(delta)


# 💀 MORTE
func morrer():

	if esta_morto:
		return

	esta_morto = true

	call_deferred("_morrer_safe")


func _morrer_safe():

	# 🎁 DROP
	var drops = DropSystem.gerar_drops()

	for item in drops:

		get_tree().current_scene.add_child(item)
		item.global_position = global_position


	# ⭐ XP
	if ultimo_atacante and ultimo_atacante.is_in_group("player"):

		UpgradeSystem.ganhar_xp(randi_range(1, 5))
		conceder_pontos()


	$hurtBox.set_deferred("monitoring", false)

	queue_free()


# 💥 RECEBER DANO
func _on_hurt_box_area_entered(area: Area2D):

	if "forca" in area and "dono" in area:

		receber_dano(
			area.forca,
			area.dono.global_position,
			area.dono
		)

	elif area.is_in_group("trap"):

		receber_dano(
			50,
			area.global_position,
			null
		)
