class_name MoverCommand
extends Command


var jogador
var direcao: Vector2


func _init(_jogador, _direcao: Vector2) -> void:
	jogador = _jogador
	direcao = _direcao


func executar() -> void:
	if jogador == null:
		return

	jogador.mover(direcao)
