extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player") and GameManager.player_tem_chave:
		GameManager.finalizar_jogo("WIN")
