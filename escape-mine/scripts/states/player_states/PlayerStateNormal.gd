class_name PlayerStateNormal
extends PlayerState

func entrar():
	player.usando_dinamite = false

func fisica(_delta: float) -> void:

	if player.esta_morrendo:
		player.state_machine.mudar_estado(&"morto")
		return

	var direcao := Vector2(
		Input.get_action_strength("right") -
		Input.get_action_strength("left"),

		Input.get_action_strength("down") -
		Input.get_action_strength("up")
	).normalized()

	player.mover(direcao)

	# Ataque
	if Input.is_action_just_pressed("attack") and not player.is_attack:
		player.state_machine.mudar_estado(&"atacando")
		return

	# Dinamite
	if Input.is_action_just_pressed("usar_item"):
		if player.inventario.usar_item("dinamite"):
			player.state_machine.mudar_estado(&"usando_dinamite")
