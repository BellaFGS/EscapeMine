class_name EnemyIterator
extends RefCounted

var _inimigos: Array[Node]
var _indice := 0


func _init(inimigos: Array[Node]) -> void:
	# A iteração usa uma foto da coleção: novos spawns entram no próximo iterator.
	_inimigos = inimigos.duplicate()


func has_next() -> bool:
	while _indice < _inimigos.size():
		var inimigo := _inimigos[_indice]
		if is_instance_valid(inimigo) and not inimigo.is_queued_for_deletion():
			return true
		_indice += 1
	return false


func next() -> Node:
	if not has_next():
		return null

	var inimigo := _inimigos[_indice]
	_indice += 1
	return inimigo
