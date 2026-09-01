class_name EnemyHurtState
extends EnemyState


func entrar():
	if is_instance_valid(inimigo):
		inimigo.is_attack = false


func sair():
	pass


func fisica(_delta: float) -> void:

	if inimigo.tomando_dano:
		inimigo.mover(Vector2.ZERO)
		return

	inimigo.state_machine.mudar_estado(&"perseguir")
