extends Control


var player
var input_manager


func _ready() -> void:

	player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("Player não encontrado para os controles mobile.")
		return

	input_manager = player.input_manager

func _on_cima_button_down() -> void:

	if input_manager:
		input_manager.definir_direcao_mobile(
			Vector2.UP
		)


func _on_cima_button_up() -> void:

	if input_manager:
		input_manager.limpar_direcao_mobile()

func _on_baixo_button_down() -> void:

	if input_manager:
		input_manager.definir_direcao_mobile(
			Vector2.DOWN
		)


func _on_baixo_button_up() -> void:

	if input_manager:
		input_manager.limpar_direcao_mobile()
		
func _on_esquerda_button_down() -> void:

	if input_manager:
		input_manager.definir_direcao_mobile(
			Vector2.LEFT
		)


func _on_esquerda_button_up() -> void:

	if input_manager:
		input_manager.limpar_direcao_mobile()
		
func _on_direita_button_down() -> void:

	if input_manager:
		input_manager.definir_direcao_mobile(
			Vector2.RIGHT
		)


func _on_direita_button_up() -> void:

	if input_manager:
		input_manager.limpar_direcao_mobile()
