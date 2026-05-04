extends Node2D

@export var item_scene: PackedScene
@export var quantidade: int = 5
@export var delay_spawn: float = 1.0


func _ready():
	if item_scene == null:
		item_scene = preload("res://scenes/items/armadilha.tscn")
	
	call_deferred("spawn_loop")

func spawn_loop() -> void:
	while is_inside_tree():
		for i in quantidade:
			
			# ⏸️ trava completamente durante pause
			while get_tree().paused:
				await get_tree().process_frame
			
			spawn_um_item()
			
			# ⏱️ timer que respeita pause manualmente
			var tempo := 2.0
			while tempo < delay_spawn:
				await get_tree().process_frame
				
				if get_tree().paused:
					continue
				
				tempo += get_process_delta_time()

func spawn_um_item():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var tentativa := 0
	var max_tentativas := 20

	while tentativa < max_tentativas:
		var angle = randf_range(0, TAU)
		var distancia = randf_range(50, 200)
		var offset = Vector2(cos(angle), sin(angle)) * distancia
		
		var pos = player.global_position + offset

		if esta_dentro_da_area(pos):
			var item = item_scene.instantiate()
			add_child(item)
			item.global_position = pos
			return
		
		tentativa += 1

func esta_dentro_da_area(pos: Vector2) -> bool:
	var space = get_world_2d().direct_space_state
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	
	var result = space.intersect_point(query)
	
	for r in result:
		if r.collider == $AreaLimite:
			return true
	
	return false
