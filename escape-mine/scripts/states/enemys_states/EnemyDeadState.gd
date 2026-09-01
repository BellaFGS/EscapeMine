class_name EnemyDeadState
extends EnemyState


func entrar():

	if inimigo.esta_morto:
		return

	inimigo.esta_morto = true
	inimigo.velocity = Vector2.ZERO
	inimigo.set_physics_process(false)

	inimigo.call_deferred("_morrer_safe")


func sair():
	pass
