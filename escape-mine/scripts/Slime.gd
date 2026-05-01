extends "res://scripts/Character.gd"

var player
var player_na_area = false

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	
	if esta_morto:
		return
	
	if player and player_na_area:
		var direcao = (player.global_position - global_position).normalized()
		mover(direcao)
	else:
		mover(Vector2.ZERO) # ou comportamento idle

# 💀 MORTE
func morrer():
	if esta_morto:
		return
	
	esta_morto = true
	call_deferred("_morrer_safe")

func _morrer_safe():
	
	# 🎁 DROP
	var drops = DropSystem.gerar_drops(GameManager.dificuldade)

	for item in drops:
		get_tree().current_scene.add_child(item)
		item.global_position = global_position
	
	# ⭐ XP
	if player:
		player.ganhar_xp(randi_range(1, 5))
	
	$hurtBox.set_deferred("monitoring", false)
	queue_free()

# 💥 RECEBER DANO
func _on_hurt_box_area_entered(area: Area2D) -> void:
	if "forca" in area and "dono" in area:
		receber_dano(area.forca, area.dono.global_position)


func _on_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		player_na_area = true

func _on_detector_body_exited(body: Node2D) -> void:
	if body == player:
		player_na_area = false
