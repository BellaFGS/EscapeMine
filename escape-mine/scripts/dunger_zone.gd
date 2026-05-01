extends Node2D

var tempo_spawn: float = 0
var intervalo_spawn: float = 1.5
@export var raio_spawn: float = 110.0
@export var item_scene: PackedScene = preload("res://scenes/items/armadilha.tscn")

func _ready():
	spawn_loop()

func spawn_loop() -> void:
	while true:
		spawn_item_ao_redor()
		await get_tree().create_timer(intervalo_spawn).timeout

func spawn_item_ao_redor():
	var player = get_tree().get_first_node_in_group("player")
	print("player:", player)
	if player == null:
		return
	if player.vida <= 0:
		return
	
	print("spawnando item")
	
	var item = item_scene.instantiate()
	get_tree().current_scene.add_child(item)

	var angle = randf_range(0, TAU)
	var distancia = randf_range(raio_spawn * 0.5, raio_spawn)

	var offset = Vector2(cos(angle), sin(angle)) * distancia
	
	item.global_position = player.global_position + offset
