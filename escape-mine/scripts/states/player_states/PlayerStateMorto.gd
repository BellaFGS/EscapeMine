class_name PlayerStateMorto
extends PlayerState

func entrar():

	player.esta_morrendo = true

	player.set_physics_process(false)

	AudioManager.tocar_sfx("morte")

	player.anim.play("lucas_death")
