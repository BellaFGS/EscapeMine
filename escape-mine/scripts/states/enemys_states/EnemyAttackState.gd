class_name EnemyAttackState
extends EnemyState

var tempo_ataque := 0.0


func entrar():
	tempo_ataque = 0.0
	inimigo.atacar()


func sair():
	pass


func atualizar(delta):

	tempo_ataque += delta

	if not inimigo.is_attack:
		inimigo.state_machine.mudar_estado(
			EnemyChaseState.new()
		)
