extends Node2D

@export var item_scene: PackedScene
@export var quantidade: int = 5
@export var area_spawn: Rect2
@export var delay_spawn: float = 1.0

func _ready():
	spawn_itens()

func spawn_itens():
	spawn_loop()

func spawn_loop() -> void:
	for i in quantidade:
		spawn_um_item()
		await get_tree().create_timer(delay_spawn).timeout

func spawn_um_item():
	var item = item_scene.instantiate()
	add_child(item)

	var pos = Vector2(
		randf_range(area_spawn.position.x, area_spawn.end.x),
		randf_range(area_spawn.position.y, area_spawn.end.y)
	)

	item.global_position = pos
