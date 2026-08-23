extends Node2D

@export var slime_scene: PackedScene
@export var esqueleto_scene: PackedScene
@export var fantasma_scene: PackedScene
@export var boss_scene: PackedScene = preload("res://scenes/characters/boss.tscn")
@export var spawn_points: Array[Node2D]

var dificuldade = "Fácil"

var tempo_spawn: float = 0
var intervalo_spawn: float = 2.5

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
# DIFICULDADE
# ============================================================

func atualizar_dificuldade(nova):
	dificuldade = nova

	match dificuldade:
		"Fácil":
			intervalo_spawn = 3.0

		"Médio":
			intervalo_spawn = 2.0

		"Difícil":
			intervalo_spawn = 1.5

		"Extremo":
			intervalo_spawn = 0.8


# ============================================================
# ESCOLHA DO INIMIGO
# ============================================================

func selecionar_enemy():
	var rand = randf()

	match dificuldade:

		"Fácil":
			if rand < 0.7:
				return criar_slime(Color.BLUE, 6, 1)
			else:
				return criar_slime(Color.GREEN, 8, 2)

		"Médio":
			if rand < 0.7:
				return criar_slime(Color.BLUE, 6, 1)
			else:
				return criar_slime(Color.GREEN, 8, 2)

		"Difícil":
			if rand < 0.5:
				return criar_slime(Color.GREEN, 10, 2)
			elif rand < 0.8:
				return criar_esqueleto(12, 3)
			else:
				return criar_slime(Color.RED, 14, 5)

		"Extremo":
			if rand < 0.4:
				return criar_slime(Color.RED, 20, 15)
			elif rand < 0.7:
				return criar_esqueleto(12, 3)
			else:
				return criar_fantasma(30, 20)

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


func criar_esqueleto(vida, forca):
	var builder = preload("res://scripts/EnemyBuilder.gd").new()

	return builder \
		.set_scene(esqueleto_scene) \
		.set_vida(vida) \
		.set_forca(forca) \
		.build()


func criar_fantasma(vida, forca):
	var builder = preload("res://scripts/EnemyBuilder.gd").new()

	return builder \
		.set_scene(fantasma_scene) \
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

	var enemy = selecionar_enemy()

	if enemy == null:
		print("enemy null")
		return

	var ponto = spawn_points.pick_random()

	enemy.global_position = ponto.global_position

	get_tree().current_scene.add_child(enemy)

	# Guarda o inimigo atual
	enemy_atual = enemy

	print("Inimigo criado: ", enemy.name)
