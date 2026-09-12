class_name PlayerInputManager
extends RefCounted


var jogador
var direcao_mobile := Vector2.ZERO


func _init(_jogador) -> void:
	jogador = _jogador


# ============================================================
# CONTROLE MOBILE
# ============================================================

func definir_direcao_mobile(direcao: Vector2) -> void:
	direcao_mobile = direcao.normalized()


func limpar_direcao_mobile() -> void:
	direcao_mobile = Vector2.ZERO


# ============================================================
# DIREÇÃO
# ============================================================

func obter_direcao() -> Vector2:

	# Se houver comando do controle mobile,
	# utiliza ele.
	if direcao_mobile != Vector2.ZERO:
		return direcao_mobile


	# Caso contrário, utiliza o teclado.
	var direcao := Vector2(
		Input.get_action_strength("right")
		- Input.get_action_strength("left"),

		Input.get_action_strength("down")
		- Input.get_action_strength("up")
	)

	return direcao.normalized()


# ============================================================
# COMMANDS
# ============================================================

func obter_comandos() -> Array[Command]:

	var comandos: Array[Command] = []

	var direcao := obter_direcao()

	comandos.append(
		MoverCommand.new(
			jogador,
			direcao
		)
	)

	return comandos
