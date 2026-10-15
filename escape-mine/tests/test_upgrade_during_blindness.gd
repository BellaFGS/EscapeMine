extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var sala := preload("res://telas/Sala1.tscn").instantiate()
	add_child(sala)
	await get_tree().process_frame
	await get_tree().process_frame

	var player := sala.get_node("player")
	UpgradeSystem.ganhar_xp(10)
	assert(UpgradeSystem.upgrade_disponivel)

	var cegueira := CegueiraDecorator.new()
	EffectManager.adicionar_efeito(player, cegueira)
	assert(cegueira.overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE)

	UIManager.abrir_upgrade()
	await get_tree().process_frame
	var tela := sala.get_node("Tela_upgrade") as CanvasLayer
	var botao := tela.get_node("HBoxContainer/PanelContainer2/forca_up") as Button
	assert(tela.layer > cegueira.canvas_layer.layer)
	assert(botao.is_visible_in_tree())
	assert(botao.get_global_rect().size.x > 0)

	_clicar(botao.get_global_rect().get_center())
	await get_tree().process_frame
	assert(UpgradeSystem.nivel == 2)
	assert(player.forca == 4)
	assert(not tela.visible)
	assert(is_instance_valid(cegueira.overlay))

	UpgradeSystem.ganhar_xp(25)
	UIManager.abrir_upgrade()
	await get_tree().process_frame
	var botao_vida := tela.get_node("HBoxContainer/PanelContainer/vida_up") as Button
	_clicar(botao_vida.get_global_rect().get_center())
	await get_tree().process_frame
	assert(UpgradeSystem.nivel == 3)
	assert(player.vida_max == 120)
	assert(not tela.visible)
	print("UPGRADE_DURING_BLINDNESS_OK")
	get_tree().quit()


func _clicar(posicao: Vector2) -> void:
	var movimento := InputEventMouseMotion.new()
	movimento.position = posicao
	movimento.global_position = posicao
	get_viewport().push_input(movimento, true)

	for pressionado in [true, false]:
		var clique := InputEventMouseButton.new()
		clique.button_index = MOUSE_BUTTON_LEFT
		clique.pressed = pressionado
		clique.position = posicao
		clique.global_position = posicao
		get_viewport().push_input(clique, true)
