extends Node

@export var tempo_restante = 60
@export var dificuldade = 1
@export var player_tem_chave = false
@export var estado = "RUNNING"

func _process(delta):
	if estado != "RUNNING":
		return

	tempo_restante -= delta

	if tempo_restante <= 0:
		aumentar_dificuldade()

func aumentar_dificuldade():
	dificuldade += 1
	tempo_restante = 60

func finalizar_jogo(resultado):
	estado = resultado
	print("Fim de jogo:", resultado)
