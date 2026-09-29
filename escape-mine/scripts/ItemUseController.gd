class_name ItemUseController
extends RefCounted

var player
var usando_item := false

var cena_dinamite = preload("res://scenes/items/dinamite_ativa.tscn")


func _init(_player) -> void:
	player = _player


func usar_dinamite() -> void:
	print("[TESTE ITEM] Chamando usar_dinamite sem disparar animação...")

	if player == null:
		print("[ERRO ITEM] Player é nulo!")
		return

	if not player.inventario.usar_item("dinamite"):
		print("[AVISO ITEM] Sem dinamites no inventário.")
		return

	# NÃO alteramos 'usando_item' para true
	# NÃO chamamos 'player.anim.play("use_dinamite")'

	# Instancia e coloca a dinamite na cena
	var dinamite = cena_dinamite.instantiate()
	player.get_parent().add_child(dinamite)
	dinamite.global_position = player.global_position + Vector2(20, 0)

	player.dinamite_up.emit(
		player.inventario.quantidade_item("dinamite")
	)

	print("[TESTE ITEM] Dinamite instanciada com sucesso, sem bloquear player!")
