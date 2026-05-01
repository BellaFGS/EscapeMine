extends Node2D

@onready var anim = $Animation

func _ready():
	anim.play("piscar")

func explodir():
	var area = $explosionArea
	area.monitoring = true

	await get_tree().process_frame # 💥 ISSO AQUI RESOLVE

	for body in area.get_overlapping_bodies():
		print("pegou:", body.name)
		if body.has_method("receber_dano"):
			body.receber_dano(100, global_position)

	anim.play("explosao")
	await anim.animation_finished
	queue_free()


func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "piscar":
		explodir()
