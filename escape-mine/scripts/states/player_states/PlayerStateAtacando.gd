class_name PlayerStateAtacando
extends PlayerState

func entrar():

	if player.esta_morrendo:
		return

	player.atacar()

func atualizar(_delta: float) -> void:

	if not player.is_attack:
		player.state_machine.mudar_estado(&"normal")
