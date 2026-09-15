class_name PlayerInputManager
extends RefCounted


var jogador
var direcao_mobile := Vector2.ZERO


func _init(_jogador) -> void:
	jogador = _jogador


func definir_direcao_mobile(direcao: Vector2) -> void:
	direcao_mobile = direcao


func limpar_direcao_mobile() -> void:
	direcao_mobile = Vector2.ZERO


func resetar() -> void:
	direcao_mobile = Vector2.ZERO


func obter_direcao() -> Vector2:
	if direcao_mobile.length() > 0.01:
		return direcao_mobile

	var direcao := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	return direcao.normalized()


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
