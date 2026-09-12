class_name AtacarCommand
extends Command


var jogador


func _init(_jogador) -> void:
	jogador = _jogador


func executar() -> void:

	if jogador == null:
		return

	jogador.atacar()
