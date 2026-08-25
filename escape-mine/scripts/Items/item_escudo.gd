extends Area2D

func aplicar(player):
	EffectManager.adicionar_efeito(
		player,
		EscudoDecorator.new()
	)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		aplicar(body)
		queue_free()
