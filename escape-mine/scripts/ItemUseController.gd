class_name ItemUseController
extends RefCounted

var player
var usando_item := false

var cena_dinamite = preload("res://scenes/items/dinamite_ativa.tscn")


func _init(_player) -> void:
	player = _player


func usar_dinamite() -> void:
	if player == null:
		return

	if not player.inventario.usar_item("dinamite"):
		
		return

	# Instancia e coloca a dinamite na cena
	var dinamite = cena_dinamite.instantiate()
	player.get_parent().add_child(dinamite)
	dinamite.global_position = player.global_position + Vector2(20, 0)

	player.dinamite_up.emit(
		player.inventario.quantidade_item("dinamite")
	)
