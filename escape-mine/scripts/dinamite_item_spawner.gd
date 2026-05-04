extends Node2D

var item_scene: PackedScene = preload("res://scenes/items/ItemDinamite.tscn")
@export var intervalo_spawn := 10.0
@export var distancia_min := 100.0
@export var distancia_max := 250.0

func _ready():
	await get_tree().process_frame
	spawn_loop()

func spawn_loop():
	while is_inside_tree():
		await get_tree().create_timer(intervalo_spawn).timeout
		
		if get_tree().paused:
			continue
		
		spawn_dinamite()

func esta_dentro_da_area(pos: Vector2) -> bool:
	var space = get_world_2d().direct_space_state
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	
	var result = space.intersect_point(query)
	
	for r in result:
		if r.collider == $AreaValida:
			return true
	
	return false

func spawn_dinamite():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var tentativa := 0
	var max_tentativas := 15

	while tentativa < max_tentativas:
		var angle = randf_range(0, TAU)
		var distancia = randf_range(distancia_min, distancia_max)
		var offset = Vector2(cos(angle), sin(angle)) * distancia
		
		var pos = player.global_position + offset

		# verifica se está dentro da Area2D
		if esta_dentro_da_area(pos):
			print("item_scene:", item_scene)
			var item = item_scene.instantiate()
			get_tree().current_scene.call_deferred("add_child", item)
			item.global_position = pos
			return
		
		tentativa += 1
