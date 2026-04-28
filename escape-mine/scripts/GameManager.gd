extends Node

signal tempo_alterado(valor)
signal dificuldade_alterada(nivel, nome)

var tempo_total: float = 0.0
var intervalo_dificuldade: float = 30.0 # a cada 30s sobe nível

var dificuldade: int = 1
var player_tem_chave = false
var estado = "RUNNING"

var enemy_spawner

func _ready():
	enemy_spawner = get_tree().get_first_node_in_group("spawner")
	atualizar_sistemas()

func _process(delta):
	if estado != "RUNNING":
		return

	tempo_total += delta
	emit_signal("tempo_alterado", tempo_total)

	# ⏱️ sobe dificuldade automaticamente
	if tempo_total >= intervalo_dificuldade:
		tempo_total = 0
		aumentar_dificuldade()

	# 🏁 condição de vitória continua igual
	if player_tem_chave:
		finalizar_jogo("WIN")

# 🎯 Nome da dificuldade
func get_dificuldade_nome():
	match dificuldade:
		1: return "Fácil"
		2: return "Médio"
		3: return "Difícil"
		_: return "Extremo"

# 📈 Aumenta dificuldade
func aumentar_dificuldade():
	dificuldade += 1
	
	var nome = get_dificuldade_nome()
	print("Dificuldade aumentou para:", nome)

	emit_signal("dificuldade_alterada", dificuldade, nome)

	atualizar_sistemas()

# 🔗 Atualiza tudo que depende da dificuldade
func atualizar_sistemas():
	var nome = get_dificuldade_nome()
	
	# EnemySpawner
	if enemy_spawner:
		enemy_spawner.atualizar_dificuldade(nome)

	# Aqui você pode plugar outros sistemas depois:
	# DropSystem
	# DangerZone
	# HUD

# 🏁 Finalização
func finalizar_jogo(resultado):
	estado = resultado
	print("Fim de jogo:", resultado)

	if resultado == "WIN":
		var tela_vitoria = preload("res://telas/tela_vitoria.tscn").instantiate()
		get_tree().current_scene.add_child(tela_vitoria)
	elif resultado == "LOSE":
		var tela_morte = preload("res://telas/tela_morte.tscn").instantiate()
		get_tree().current_scene.add_child(tela_morte)

# 🔄 Reset
func resetar():
	estado = "RUNNING"
	tempo_total = 0
	dificuldade = 1
	player_tem_chave = false
	atualizar_sistemas()
