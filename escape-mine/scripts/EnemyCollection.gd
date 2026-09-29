class_name EnemyCollection
extends RefCounted

var _arvore: SceneTree


func _init(arvore: SceneTree) -> void:
	_arvore = arvore


func criar_iterator() -> EnemyIterator:
	var inimigos: Array[Node] = []
	for node in _arvore.get_nodes_in_group("enemy"):
		# Algumas áreas de ataque do Boss também estão no grupo.
		if node is CharacterBody2D and node.has_method("receber_dano"):
			inimigos.append(node)
	return EnemyIterator.new(inimigos)
