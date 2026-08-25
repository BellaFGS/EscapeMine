extends Node2D

@export var slime_scene: PackedScene
@export var boss_scene: PackedScene = preload("res://scenes/characters/boss.tscn")
@export var spawn_points: Array[Node2D]

@export var intervalo_spawn: float = 2.5

var tempo_spawn: float = 0

# Guarda o inimigo que está atualmente no mapa
var enemy_atual: Node2D = null


func _process(delta):
	# Se já existe um inimigo vivo, não cria outro
	if enemy_atual != null and is_instance_valid(enemy_atual):
		return

	tempo_spawn += delta

	if tempo_spawn >= intervalo_spawn:
		tempo_spawn = 0
		spawn_enemy()


# ============================================================
# ESCOLHA ALEATÓRIA DO SLIME
# ============================================================

func selecionar_enemy():
	var tipo_slime = randi_range(0, 2)

	match tipo_slime:
		0:
			return criar_slime(Color.BLUE, 6, 1)

		1:
			return criar_slime(Color.GREEN, 8, 2)

		2:
			return criar_slime(Color.RED, 14, 5)

	return null


# ============================================================
# BUILDERS
# ============================================================

func criar_slime(cor, vida, forca):
	var builder = preload("res://scripts/EnemyBuilder.gd").new()

	return builder \
		.set_scene(slime_scene) \
		.set_color(cor) \
		.set_vida(vida) \
		.set_forca(forca) \
		.build()


func criar_boss(vida, forca):
	var builder = preload("res://scripts/EnemyBuilder.gd").new()

	return builder \
		.set_scene(boss_scene) \
		.set_vida(vida) \
		.set_forca(forca) \
		.build()


# ============================================================
# SPAWN
# ============================================================

func spawn_enemy():
	print("spawnando...")

	# Segurança extra
	if enemy_atual != null and is_instance_valid(enemy_atual):
		print("Já existe um inimigo!")
		return

	if spawn_points.is_empty():
		print("SEM SPAWN POINT")
		return

	# Escolhe aleatoriamente o tipo de slime
	var enemy = selecionar_enemy()

	if enemy == null:
		print("enemy null")
		return

	# Escolhe aleatoriamente o ponto de spawn
	var ponto = spawn_points.pick_random()

	enemy.global_position = ponto.global_position

	get_tree().current_scene.add_child(enemy)

	# Guarda o inimigo atual
	enemy_atual = enemy

	print("Inimigo criado: ", enemy.name)
