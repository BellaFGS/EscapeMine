class_name EscudoDecorator
extends EffectDecorator

var alvo

func aplicar(novo_alvo):

	alvo = novo_alvo

	print("ESCUDO ATIVADO")

	# efeito visual opcional
	alvo.modulate = Color(0.5, 0.8, 1)

	await alvo.get_tree().create_timer(5.0).timeout

	remover(alvo)

func remover(alvo):

	print("ESCUDO REMOVIDO")

	alvo.modulate = Color.WHITE

	EffectManager.remover_efeito(
		alvo,
		self
	)
