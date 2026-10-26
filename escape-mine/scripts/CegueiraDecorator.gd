
class_name CegueiraDecorator
extends EffectDecorator

var alvo
var canvas_layer
var overlay

func aplicar(novo_alvo):
	alvo = novo_alvo

	# Camada visual sobre o jogo
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 5

	# Retângulo que cobre toda a tela
	overlay = ColorRect.new()
	overlay.color = Color.WHITE
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# Shader com gradiente radial
	var shader := Shader.new()
	shader.code = """
	shader_type canvas_item;

	uniform vec2 centro = vec2(0.5, 0.5);
	uniform float raio = 0.22;
	uniform float suavidade = 0.18;
	uniform float escuridao = 0.90;

	void fragment() {
		vec2 uv = SCREEN_UV;

		// Corrige a proporção da tela para formar um círculo
		vec2 aspecto = vec2(
			SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x,
			1.0
		);

		float distancia = length((uv - centro) * aspecto);

		float mascara = smoothstep(
			raio,
			raio + suavidade,
			distancia
		);

		float alpha = mascara * escuridao;

		COLOR = vec4(0.0, 0.0, 0.0, alpha);
	}
	"""

	var material := ShaderMaterial.new()
	material.shader = shader
	overlay.material = material

	canvas_layer.add_child(overlay)
	alvo.get_tree().current_scene.add_child(canvas_layer)

	print("CEGUEIRA RADIAL APLICADA")

	await alvo.get_tree().create_timer(5.0).timeout

	remover(alvo)


func remover(alvo):
	if is_instance_valid(canvas_layer):
		canvas_layer.queue_free()

	EffectManager.remover_efeito(
		alvo,
		self
	)
