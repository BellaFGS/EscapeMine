extends "res://scripts/Character.gd"

var player

func _ready():
	player = get_tree().get_first_node_in_group("player")
	speed += GameManager.dificuldade * 10
	vida += GameManager.dificuldade * 10
	dano += GameManager.dificuldade * 2

func _physics_process(delta):
	if player:
		var direcao = (player.global_position - global_position).normalized()
		mover(direcao)

func morrer():
	var item_scene = DropSystem.gerar_drop()

	if item_scene:
		var item = item_scene.instantiate()
		get_parent().add_child(item)
		item.global_position = global_position

	queue_free()
