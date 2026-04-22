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
	if esta_morto:
		return
	esta_morto = true
	call_deferred("_morrer_safe")

func _morrer_safe():
	var item_scene = DropSystem.gerar_drop()

	if item_scene:
		var item = item_scene.instantiate()
		
		var scene = get_tree().current_scene
		if scene:
			scene.add_child(item)
			item.global_position = global_position

	$hurtBox.set_deferred("monitoring", false)
	queue_free()

func _on_hurt_box_area_entered(area: Area2D) -> void:
	print("colidiu com:", area)
	if "dano" in area and "dono" in area:
		receber_dano(area.dano, area.dono.global_position)
		print("Player me bateu")
