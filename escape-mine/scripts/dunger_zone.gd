extends Node2D


@export var area_spawn: Area2D

@export var intervalo_spawn: float = 1.5

@export var item_scene: PackedScene = preload(
	"res://scenes/items/armadilha.tscn"
)


func _ready():

	# Começa o sistema de spawn
	spawn_loop()


# ============================================================
# LOOP DE SPAWN
# ============================================================

func spawn_loop() -> void:

	while is_inside_tree():

		await get_tree().create_timer(
			intervalo_spawn
		).timeout


		# Verifica se o jogo ainda está rodando
		if GameManager.estado != "RUNNING":
			continue


		# Não spawna enquanto o jogo estiver pausado
		if get_tree().paused:
			continue


		spawn_item()


# ============================================================
# SPAWN
# ============================================================

func spawn_item():

	if area_spawn == null:

		push_error(
			"SpawnerArmadilha: Area2D de spawn não configurada!"
		)

		return


	if item_scene == null:

		push_error(
			"SpawnerArmadilha: item_scene não configurada!"
		)

		return


	var player = get_tree().get_first_node_in_group("player")


	if player == null:
		return


	if player.vida <= 0:
		return


	var collision_shape = area_spawn.get_node_or_null(
		"collision"
	)


	if collision_shape == null:

		push_error(
			"SpawnerArmadilha: AreaSpawn precisa ter um CollisionShape2D!"
		)

		return


	if collision_shape.shape == null:

		push_error(
			"SpawnerArmadilha: CollisionShape2D não possui Shape!"
		)

		return


	# Verifica se é um RectangleShape2D
	if not collision_shape.shape is RectangleShape2D:

		push_error(
			"SpawnerArmadilha: use um RectangleShape2D na AreaSpawn!"
		)

		return


	var shape := collision_shape.shape as RectangleShape2D

	var tamanho := shape.size


	# Escolhe uma posição aleatória dentro do retângulo
	var x = randf_range(
		-tamanho.x / 2.0,
		tamanho.x / 2.0
	)

	var y = randf_range(
		-tamanho.y / 2.0,
		tamanho.y / 2.0
	)


	var posicao_local = Vector2(x, y)


	# Converte a posição da área para posição global
	var posicao_global = (
		collision_shape.global_transform
		* posicao_local
	)


	# Cria a armadilha
	var item = item_scene.instantiate()

	get_tree().current_scene.add_child(item)

	item.global_position = posicao_global


	print(
		"Armadilha criada em: ",
		item.global_position
	)
