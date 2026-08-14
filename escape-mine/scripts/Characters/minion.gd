extends "res://scripts/Character.gd"


var player
var ja_explodiu = false


func _ready():
	player = get_tree().get_first_node_in_group("player")

	var hitbox = get_node_or_null("hitBox")
	if hitbox:
		hitbox.forca = forca
		hitbox.dono = self
		hitbox.monitoring = true

		var colisao = hitbox.get_node_or_null("Collision")
		if colisao:
			colisao.disabled = false

		hitbox.area_entered.connect(_on_hit_box_area_entered)


func _physics_process(delta):
	if esta_morto or ja_explodiu:
		return

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return

	var direcao = (
		player.global_position -
		global_position
	).normalized()

	mover(direcao)


func _on_hit_box_area_entered(area: Area2D) -> void:
	if ja_explodiu or esta_morto:
		return

	var atingido = area.get_parent()
	if not (atingido and atingido.is_in_group("player")):
		return

	ja_explodiu = true
	morrer()


# 💀 MORTE
func morrer():
	if esta_morto:
		return

	esta_morto = true

	call_deferred("_morrer_safe")


func _morrer_safe():
	$hurtBox.set_deferred(
		"monitoring",
		false
	)

	var hitbox = get_node_or_null("hitBox")
	if hitbox:
		hitbox.set_deferred("monitoring", false)

	queue_free()


# 💥 RECEBER DANO
func _on_hurt_box_area_entered(area: Area2D) -> void:
	if "forca" in area and "dono" in area:
		receber_dano(
			area.forca,
			area.dono.global_position,
			area.dono
		)

	elif area.is_in_group("trap"):
		receber_dano(
			50,
			area.global_position,
			null
		)
