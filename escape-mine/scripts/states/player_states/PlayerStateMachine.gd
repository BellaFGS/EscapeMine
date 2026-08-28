class_name PlayerStateMachine
extends StateMachine

var player
var estados: Dictionary = {}


func inicializar(p):
	player = p
	personagem = p

	estados["normal"] = PlayerStateNormal.new()
	estados["atacando"] = PlayerStateAtacando.new()
	estados["usando_dinamite"] = PlayerStateUsandoDinamite.new()
	estados["morto"] = PlayerStateMorto.new()

	for estado in estados.values():
		estado.player = player

	mudar_estado("normal")


func mudar_estado(nome: String):
	if not estados.has(nome):
		return

	if estado_atual:
		estado_atual.sair()

	estado_atual = estados[nome]

	estado_atual.entrar()


func atualizar(delta):
	if estado_atual:
		estado_atual.atualizar(delta)


func fisica(delta):
	if estado_atual:
		estado_atual.fisica(delta)
