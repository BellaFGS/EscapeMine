class_name PlayerStateAtacando
extends PlayerState

func entrar():

	if player.esta_morrendo:
		return

	player.atacar()

func atualizar(_delta):

	if not player.is_attack:
		player.state_machine.mudar_estado("normal")
