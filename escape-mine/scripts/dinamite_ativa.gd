extends Node2D

@onready var anim = $Animation
func _ready():
	anim.play("piscar")

func explodir():
	var area = $explosionArea
	
	area.forca = 50
	area.dono = self
	area.monitoring = true

	anim.play("explosao")
	await anim.animation_finished
	queue_free()


func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "piscar":
		explodir()
