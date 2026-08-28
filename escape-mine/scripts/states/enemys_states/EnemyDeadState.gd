class_name EnemyDeadState
extends EnemyState


func entrar():

	if inimigo.esta_morto:
		return

	inimigo.esta_morto = true

	inimigo.call_deferred("_morrer_safe")


func sair():
	pass
