class_name StateMachine
extends RefCounted

var personagem
var estado_atual


func mudar_estado(novo_estado):
	if estado_atual:
		estado_atual.sair()

	estado_atual = novo_estado

	if estado_atual:
		estado_atual.entrar()


func atualizar(delta):
	if estado_atual:
		estado_atual.atualizar(delta)


func fisica(delta):
	if estado_atual:
		estado_atual.fisica(delta)
