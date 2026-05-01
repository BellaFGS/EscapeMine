extends Node2D

@onready var anim = $Animation

func _ready():
	anim.play("piscar")

func explodir():
	var area = $explosionArea
	area.monitoring = true
	area.forca = 50
	area.dono = self
	
	for body in get_tree().get_nodes_in_group("enemy"):
		body.receber_dano(50, global_position)
	for body in get_tree().get_nodes_in_group("player"):
		body.receber_dano(50, global_position)
	await get_tree().physics_frame

	anim.play("explosao")
	await anim.animation_finished
	queue_free()


func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "piscar":
		explodir()
