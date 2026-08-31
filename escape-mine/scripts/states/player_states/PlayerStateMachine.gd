class_name PlayerStateMachine
extends StateMachine

var player
var estados: Dictionary = {}


func inicializar(p) -> void:
	player = p
	personagem = p
	estados.clear()

	estados[&"normal"] = PlayerStateNormal.new()
	estados[&"atacando"] = PlayerStateAtacando.new()
	estados[&"usando_dinamite"] = PlayerStateUsandoDinamite.new()
	estados[&"morto"] = PlayerStateMorto.new()

	for estado in estados.values():
		estado.player = player
		estado.personagem = player

	mudar_estado(&"normal")


func mudar_estado(nome: StringName) -> void:
	if not estados.has(nome):
		push_warning("PlayerStateMachine: estado desconhecido: " + String(nome))
		return

	definir_estado(estados[nome])
