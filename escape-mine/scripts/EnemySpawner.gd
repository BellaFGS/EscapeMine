extends Node2D

@export var enemy_scene: PackedScene
@export var intervalo = 5.0

var timer = 0

func _process(delta):
	if GameManager.estado != "RUNNING":
		return

	timer -= delta

	if timer <= 0:
		spawn_enemy()
		timer = intervalo / GameManager.dificuldade

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	add_child(enemy)

	enemy.global_position = Vector2(
		randi_range(100, 500),
		randi_range(100, 500)
	)
