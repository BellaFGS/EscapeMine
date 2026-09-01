class_name EnemyStateMachine
extends StateMachine

var inimigo
var estados: Dictionary = {}


func inicializar(alvo) -> void:
	inimigo = alvo
	personagem = alvo
	estados.clear()

	estados[&"perseguir"] = EnemyChaseState.new()
	estados[&"atacar"] = EnemyAttackState.new()
	estados[&"ferido"] = EnemyHurtState.new()
	estados[&"morto"] = EnemyDeadState.new()

	for estado in estados.values():
		estado.inimigo = inimigo
		estado.personagem = inimigo

	mudar_estado(&"perseguir")

func mudar_estado(nome: StringName) -> void:
	if not estados.has(nome):
		push_warning("EnemyStateMachine: estado desconhecido: " + String(nome))
		return

	definir_estado(estados[nome])
