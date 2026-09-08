class_name StateMachine
extends RefCounted

var personagem: CharacterBody2D
var estado_atual: CharacterState


func mudar_estado(_nome: StringName) -> void:
	push_warning("StateMachine: mudar_estado deve ser implementado pela maquina concreta.")


func definir_estado(novo_estado: CharacterState) -> void:
	if novo_estado == estado_atual:
		return

	if estado_atual:
		estado_atual.sair()

	estado_atual = novo_estado

	if estado_atual:
		estado_atual.entrar()


func atualizar(delta: float) -> void:
	if estado_atual:
		estado_atual.atualizar(delta)


func fisica(delta: float) -> void:
	if estado_atual:
		estado_atual.fisica(delta)
