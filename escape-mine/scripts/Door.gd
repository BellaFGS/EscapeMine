extends Area2D

@onready var anim = $Animation

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.is_in_group("player") and GameManager.player_tem_chave:
		anim.play("abrir")
		await anim.animation_finished
		queue_free()
		GameManager.finalizar_jogo("WIN")
	else:
		anim.play("mexer")
		await anim.animation_finished
