class_name EscudoDecorator
extends EffectDecorator

var alvo

func aplicar(novo_alvo):
	alvo = novo_alvo

	print("ESCUDO ATIVADO")

	# Efeito visual opcional
	alvo.modulate = Color(0.5, 0.8, 1)

	await alvo.get_tree().create_timer(5.0).timeout

	remover(alvo)

func remover(alvo_para_remover):
	print("ESCUDO REMOVIDO")

	# Valida se o nó ainda existe na memória antes de modificar
	if is_instance_valid(alvo_para_remover):
		alvo_para_remover.modulate = Color.WHITE

		EffectManager.remover_efeito(
			alvo_para_remover,
			self
		)
