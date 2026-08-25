extends Node2D


@export var esqueleto_scene: PackedScene
@export var fantasma_scene: PackedScene

@export var spawn_points: Array[Node2D]

@export var intervalo_spawn: float = 10.0


var player_dentro: bool = false
var tempo_spawn: float = 0.0


func _ready():
	pass


func _process(delta):

	if not player_dentro:
		return

	tempo_spawn += delta

	if tempo_spawn >= intervalo_spawn:

		tempo_spawn = 0

		spawn_enemy()


# ============================================================
# CONTROLE DO SPAWNER
# ============================================================

func ativar():

	player_dentro = true

	# Reseta o contador
	tempo_spawn = 0

	print("ObserverSpawner ativado.")

	# Spawn imediato ao entrar na área
	spawn_enemy()


func desativar():

	player_dentro = false

	# Reseta o contador
	tempo_spawn = 0

	print("ObserverSpawner desativado.")


# ============================================================
# SPAWN
# ============================================================

func spawn_enemy():

	if spawn_points.is_empty():

		push_error(
			"ObserverSpawner: nenhum SpawnPoint configurado!"
		)

		return


	print("===== NOVA ONDA DE INIMIGOS =====")


	# Percorre TODOS os pontos de spawn
	for ponto in spawn_points:

		if ponto == null:
			continue


		var enemy


		# Escolhe aleatoriamente o tipo de inimigo
		if randf() < 0.5:

			enemy = criar_esqueleto(12, 3)

		else:

			enemy = criar_fantasma(30, 20)


		if enemy == null:

			push_error(
				"ObserverSpawner: não foi possível criar o inimigo."
			)

			continue


		# Coloca o inimigo exatamente no SpawnPoint
		enemy.global_position = ponto.global_position


		# Adiciona o inimigo na cena
		get_tree().current_scene.add_child(enemy)


		print(
			"Inimigo criado no ",
			ponto.name,
			": ",
			enemy.name
		)


# ============================================================
# BUILDER
# ============================================================

func criar_esqueleto(vida, forca):

	var builder = preload(
		"res://scripts/EnemyBuilder.gd"
	).new()


	return builder \
		.set_scene(esqueleto_scene) \
		.set_vida(vida) \
		.set_forca(forca) \
		.build()


func criar_fantasma(vida, forca):

	var builder = preload(
		"res://scripts/EnemyBuilder.gd"
	).new()


	return builder \
		.set_scene(fantasma_scene) \
		.set_vida(vida) \
		.set_forca(forca) \
		.build()
