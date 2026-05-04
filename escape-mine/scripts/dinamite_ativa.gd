extends Node2D

@onready var anim = $Animation
@onready var area = $explosionArea

func _ready():
	anim.play("piscar")

func explodir():
	# configura dano
	area.forca = 50
	area.dono = self
	
	# 💣 evita detectar coisas antigas
	area.monitoring = false
	await get_tree().process_frame
	area.monitoring = true

	# aplica dano manualmente
	for body in area.get_overlapping_bodies():
		if body.is_in_group("enemy") or body.is_in_group("player"):
			body.receber_dano(area.forca, global_position)

	# animação
	anim.play("explosao")
	await anim.animation_finished
	
	queue_free()


func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "piscar":
		explodir()
