class_name EnemyHurtState
extends EnemyState


func entrar():
	pass


func sair():
	pass


func fisica(_delta):

	if inimigo.tomando_dano:
		inimigo.mover(Vector2.ZERO)
		return

	inimigo.state_machine.mudar_estado(
		EnemyChaseState.new()
	)
