class_name EnemyState
extends RefCounted

var inimigo


func entrar():
	pass


func sair():
	pass


func atualizar(_delta):
	pass


func fisica(_delta):
	pass


func obter_player():
	if not is_instance_valid(inimigo):
		return null

	return inimigo.player
