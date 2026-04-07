extends Node2D

@export var enemy_scene: PackedScene
var intervalo = 5.0
var timer = 0

func _ready() -> void:
	timer = 5.0

func _process(delta):
	if GameManager.estado != "RUNNING":
		return
	timer -= delta

	if timer <= 0:
		spawn_enemy()
		timer = intervalo / GameManager.dificuldade

func spawn_enemy():
	var player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
	
	var posicao_spawn
	var distancia_minima = 200
	
	while true:
		posicao_spawn = Vector2(
			randi_range(100, 500),
			randi_range(100, 500)
		)
		
		if posicao_spawn.distance_to(player.global_position) > distancia_minima:
			break
	
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = posicao_spawn
