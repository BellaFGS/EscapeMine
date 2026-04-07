extends Node

signal tempo_alterado(valor)

var tempo_restante = 60
var dificuldade = 1
var player_tem_chave = false
var estado = "RUNNING"

func _process(delta):
	if estado != "RUNNING":
		return

	tempo_restante -= delta
	emit_signal("tempo_alterado", tempo_restante)

	if tempo_restante <= 0:
		aumentar_dificuldade()
	
	if player_tem_chave == true:
		finalizar_jogo("WIN")

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

func resetar():
	estado = "RUNNING"
	tempo_restante = 60
	dificuldade = 1
	player_tem_chave = false
