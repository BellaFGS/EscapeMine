extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var primeiro := _criar_inimigo()
	var segundo := _criar_inimigo()
	var area_do_boss := Area2D.new()
	area_do_boss.add_to_group("enemy")
	root.add_child(area_do_boss)

	var iterator := EnemyCollection.new(self).criar_iterator()
	var terceiro := _criar_inimigo()
	assert(iterator.next() == primeiro)
	segundo.queue_free()
	assert(not iterator.has_next())
	assert(iterator.next() == null)

	var novo_iterator := EnemyCollection.new(self).criar_iterator()
	assert(novo_iterator.next() == primeiro)
	assert(novo_iterator.next() == terceiro)
	assert(not novo_iterator.has_next())

	await _testar_explosao()

	print("ENEMY_ITERATOR_OK")
	quit()


func _criar_inimigo() -> CharacterBody2D:
	var inimigo := CharacterBody2D.new()
	inimigo.set_script(load("res://scripts/Character.gd"))
	inimigo.add_to_group("enemy")
	root.add_child(inimigo)
	return inimigo


func _testar_explosao() -> void:
	var inimigo := _criar_inimigo()
	var hurtbox := Area2D.new()
	hurtbox.collision_layer = 2
	hurtbox.collision_mask = 0
	var colisao_inimigo := CollisionShape2D.new()
	var forma_inimigo := CircleShape2D.new()
	forma_inimigo.radius = 10
	colisao_inimigo.shape = forma_inimigo
	hurtbox.add_child(colisao_inimigo)
	inimigo.add_child(hurtbox)

	var explosao := Area2D.new()
	explosao.set_script(load("res://scripts/explosion_area.gd"))
	explosao.collision_layer = 0
	explosao.collision_mask = 2
	explosao.forca = 2
	var colisao_explosao := CollisionShape2D.new()
	var forma_explosao := CircleShape2D.new()
	forma_explosao.radius = 20
	colisao_explosao.shape = forma_explosao
	explosao.add_child(colisao_explosao)
	root.add_child(explosao)

	await physics_frame
	await physics_frame
	assert(inimigo.vida == 3)
