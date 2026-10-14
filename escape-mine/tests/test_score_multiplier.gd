extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var casos := [
		{"tempo": 300.0, "multiplicador": 3},
		{"tempo": 300.01, "multiplicador": 2},
		{"tempo": 600.0, "multiplicador": 2},
		{"tempo": 600.01, "multiplicador": 1},
	]

	for caso in casos:
		GameManager.resetar()
		ScoreManager.adicionar_pontos(100)
		GameManager.tempo_total = caso.tempo
		ScoreManager.finalizar_partida("WIN")
		assert(ScoreManager.multiplicador_tempo == caso.multiplicador)
		assert(ScoreManager.obter_pontuacao_final() == 100 * caso.multiplicador)

	GameManager.resetar()
	ScoreManager.adicionar_pontos(100)
	GameManager.tempo_total = 300.0
	ScoreManager.finalizar_partida("WIN")
	GameManager.tempo_total = 601.0
	assert(ScoreManager.obter_pontuacao_final() == 300)

	# Usa registros em memória; o teste não grava no ranking do jogador.
	ScoreManager._registros = [{"nome": "TESTE", "pontos": 300, "multiplicador": 3}]
	var tela := preload("res://telas/tela_resultado.tscn").instantiate()
	add_child(tela)
	assert("0000300" in tela.pontos.text)
	assert("x3" in tela.multiplicador.text)
	assert("0000300  x3" in tela.ranking.text)

	var item := preload("res://telas/ranking_item.tscn").instantiate()
	add_child(item)
	item.configurar({"nome": "TESTE", "pontos": 300, "multiplicador": 3}, 1)
	assert(item.pontuacao.text == "300 (x3)")
	item.configurar({"nome": "ANTIGO", "pontos": 100}, 2)
	assert(item.pontuacao.text == "100 (x1)")

	print("SCORE_MULTIPLIER_OK")
	get_tree().quit()
