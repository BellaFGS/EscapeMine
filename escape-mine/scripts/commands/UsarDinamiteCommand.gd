class_name UsarDinamiteCommand
extends Command


var jogador


func _init(_jogador) -> void:
	jogador = _jogador


func executar() -> void:

	if jogador == null:
		return

	jogador.usar_dinamite()

func _on_botao_dinamite_pressed() -> void:

	if player == null:
		return

	var comando := UsarDinamiteCommand.new(player)

	comando.executar()
