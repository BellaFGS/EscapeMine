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

	# Instancia a tela correspondente
	if resultado == "WIN":
		var tela_vitoria = preload("res://telas/tela_vitoria.tscn").instantiate()
		get_tree().current_scene.add_child(tela_vitoria)
	elif resultado == "LOSE":
		var tela_morte = preload("res://telas/tela_morte.tscn").instantiate()
		get_tree().current_scene.add_child(tela_morte)
