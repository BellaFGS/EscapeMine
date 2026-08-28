class_name PlayerStateUsandoDinamite
extends PlayerState

func entrar():

	player.usando_dinamite = true

	player.anim.play("use_dinamite")

	var d = player.cena_dinamite.instantiate()

	player.get_parent().add_child(d)

	d.global_position = (
		player.global_position + Vector2(20, 0)
	)

	player.dinamite -= 1

	player.emit_signal(
		"dinamite_up",
		player.dinamite
	)

func atualizar(_delta):

	if not player.usando_dinamite:
		player.state_machine.mudar_estado("normal")
