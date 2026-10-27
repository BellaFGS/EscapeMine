extends Node


func _ready() -> void:
	if not has_meta("persistent_runner"):
		var runner := Node.new()
		runner.set_meta("persistent_runner", true)
		runner.set_script(get_script())
		get_tree().root.add_child.call_deferred(runner)
		return

	process_mode = Node.PROCESS_MODE_ALWAYS
	_run_test()


func _run_test() -> void:
	GameManager.resetar()
	GameManager.tempo_total = 120.0
	GameManager.player_vida_max = 120
	GameManager.player_forca = 4
	GameManager.player_dinamite = 2
	UpgradeSystem.restaurar_checkpoint(2, 7)
	ScoreManager.adicionar_pontos(100)

	get_tree().change_scene_to_file("res://telas/sala3.tscn")
	await get_tree().scene_changed
	get_tree().paused = true
	await get_tree().process_frame
	var player: Node2D = get_tree().get_first_node_in_group("player")
	assert(player != null)
	assert(BossCheckpointManager.tem_checkpoint())
	var posicao := player.global_position
	var tempo_checkpoint := GameManager.tempo_total
	var chefe := get_tree().current_scene.get_node("Boss")

	player.vida = 1
	player.forca = 99
	player.inventario.itens["dinamite"] = 0
	GameManager.tempo_total = 250.0
	UpgradeSystem.restaurar_checkpoint(5, 20)
	ScoreManager.adicionar_pontos(50)
	GameManager.finalizar_jogo("LOSE")
	await get_tree().scene_changed
	var resultado = get_tree().current_scene
	assert(resultado.tentar_chefe.visible)
	assert(
		resultado.tentar_chefe.get_global_rect().end.y
		<= resultado.get_viewport().get_visible_rect().end.y
	)
	resultado.tentar_chefe.pressed.emit()
	await get_tree().scene_changed
	get_tree().paused = true
	await get_tree().process_frame

	player = get_tree().get_first_node_in_group("player")
	assert(player != null)
	assert(not is_instance_valid(chefe))
	assert(player.global_position == posicao)
	assert(player.vida == 120 and player.vida_max == 120)
	assert(player.forca == 4)
	assert(player.inventario.quantidade_item("dinamite") == 2)
	assert(absf(GameManager.tempo_total - tempo_checkpoint) < 1.0)
	assert(UpgradeSystem.nivel == 2 and UpgradeSystem.xp == 7)
	assert(ScoreManager.pontuacao_atual == 80)
	assert(BossCheckpointManager.obter_tentativas() == 1)

	ScoreManager.adicionar_pontos(50)
	GameManager.finalizar_jogo("LOSE")
	await get_tree().scene_changed
	resultado = get_tree().current_scene
	assert(resultado.tentar_chefe.visible)
	resultado.tentar_chefe.pressed.emit()
	await get_tree().scene_changed
	get_tree().paused = true
	await get_tree().process_frame
	assert(ScoreManager.pontuacao_atual == 60)
	assert(BossCheckpointManager.obter_tentativas() == 2)

	GameManager.finalizar_jogo("WIN")
	await get_tree().scene_changed
	resultado = get_tree().current_scene
	assert(ScoreManager.multiplicador_tempo == 1)
	assert(ScoreManager.obter_pontuacao_final() == 60)
	assert(not resultado.tentar_chefe.visible)
	assert("x1" in resultado.multiplicador.text)

	GameManager.resetar()
	assert(not BossCheckpointManager.tem_checkpoint())
	print("BOSS_CHECKPOINT_OK")
	var tree := get_tree()
	queue_free()
	tree.quit.call_deferred()
