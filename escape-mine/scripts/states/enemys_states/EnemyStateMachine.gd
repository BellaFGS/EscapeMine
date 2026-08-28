class_name EnemyStateMachine
extends StateMachine

var inimigo


func inicializar(alvo):
	inimigo = alvo
	personagem = alvo

	var estado = EnemyChaseState.new()
	estado.inimigo = inimigo

	estado_atual = estado
	estado_atual.entrar()


func mudar_estado(novo_estado):
	if estado_atual:
		estado_atual.sair()

	estado_atual = novo_estado

	if estado_atual:
		estado_atual.inimigo = inimigo
		estado_atual.entrar()


func atualizar(delta):
	if estado_atual:
		estado_atual.atualizar(delta)


func fisica(delta):
	if estado_atual:
		estado_atual.fisica(delta)
