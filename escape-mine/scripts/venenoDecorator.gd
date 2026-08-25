class_name VenenoDecorator
extends EffectDecorator

func aplicar(alvo):

	for i in range(5):

		await alvo.get_tree().create_timer(1.0).timeout

		if !is_instance_valid(alvo):
			return

		alvo.receber_dano(
			10,
			alvo.global_position
		)

	remover(alvo)

func remover(alvo):

	EffectManager.remover_efeito(
		alvo,
		self
	)
