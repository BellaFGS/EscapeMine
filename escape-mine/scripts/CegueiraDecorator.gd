class_name CegueiraDecorator
extends EffectDecorator

var alvo
var canvas_layer
var overlay

func aplicar(novo_alvo):

	alvo = novo_alvo

	# CanvasLayer
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 999

	# Tela preta
	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.8)

	overlay.set_anchors_preset(
		Control.PRESET_FULL_RECT
	)

	canvas_layer.add_child(overlay)
	print("CEGUEIRA APLICADA")

	alvo.get_tree().current_scene.add_child(
		canvas_layer
	)

	await alvo.get_tree().create_timer(5.0).timeout

	remover(alvo)

func remover(alvo):

	if is_instance_valid(canvas_layer):
		canvas_layer.queue_free()

	EffectManager.remover_efeito(
		alvo,
		self
	)
