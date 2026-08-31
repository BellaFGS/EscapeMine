class_name EnemyState
extends CharacterState

var inimigo


func entrar():
	pass


func sair():
	pass


func atualizar(_delta: float):
	pass


func fisica(_delta: float):
	pass


func obter_player():
	if not is_instance_valid(inimigo):
		return null

	return inimigo.player
