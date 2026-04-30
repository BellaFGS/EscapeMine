extends Node2D

@export var prototipos: Array[Item]
@export var spawn_points: Array[Node2D]

func spawn_itens():
	for ponto in spawn_points:
		var proto = prototipos.pick_random()
		
		var item = proto.clonar()
		
		get_tree().current_scene.add_child(item)
		item.global_position = ponto.global_position
