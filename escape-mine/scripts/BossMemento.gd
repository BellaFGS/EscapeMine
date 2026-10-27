class_name BossMemento
extends RefCounted

var _estado: Dictionary


func _init(estado: Dictionary) -> void:
	_estado = estado.duplicate(true)


func obter_estado() -> Dictionary:
	return _estado.duplicate(true)
