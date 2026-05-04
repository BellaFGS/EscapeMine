extends Node2D

@export var slime_scene: PackedScene
@export var esqueleto_scene: PackedScene
@export var fantasma_scene: PackedScene
@export var spawn_points: Array[Node2D]

var dificuldade = "Fácil"

var tempo_spawn: float = 0
var intervalo_spawn: float = 2.5

func _process(delta):

	tempo_spawn += delta
	
	if tempo_spawn >= intervalo_spawn:
		tempo_spawn = 0
		spawn_enemy()

# 🎯 Atualiza dificuldade
func atualizar_dificuldade(nova):
	dificuldade = nova
	
	match dificuldade:
		"Fácil":
			intervalo_spawn = 2.5
		"Médio":
			intervalo_spawn = 2.0
		"Difícil":
			intervalo_spawn = 1.5
		"Extremo":
			intervalo_spawn = 1.0

# 🎲 Escolha do inimigo
func selecionar_enemy():
	var rand = randf()
	
	match dificuldade:
		"Fácil":
			return criar_slime(Color.YELLOW, 5, 10)
			return esqueleto_scene.instantiate()
		"Médio":
			if rand < 0.7:
				return criar_slime(Color.BLUE, 6, 1)
			else:
				return criar_slime(Color.GREEN, 8, 2)
		
		"Difícil":
			if rand < 0.5:
				return criar_slime(Color.GREEN, 10, 2)
			elif rand < 0.8:
				return esqueleto_scene.instantiate()
			else:
				return criar_slime(Color.RED, 14, 3)
		
		"Extremo":
			if rand < 0.4:
				return criar_slime(Color.RED, 16, 4)
			elif rand < 0.7:
				return esqueleto_scene.instantiate()
			else:
				return fantasma_scene.instantiate()

# 🟢 Builder
func criar_slime(cor, vida, forca):
	var builder = preload("res://scripts/EnemyBuilder.gd").new()
	builder.slime_scene = slime_scene
	
	return builder \
		.set_color(cor) \
		.set_vida(vida) \
		.set_forca(forca) \
		.build()

# 📍 Spawn
func spawn_enemy():
	print("spawnando...")

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
