extends Area2D

var forca: int = 0
var dono: Node = null

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_explosionArea_area_entered"))

	await get_tree().physics_frame

	# Aplica nos inimigos presentes na área por meio da coleção/iterator.
	# Os outros alvos (como o player) seguem usando as áreas sobrepostas.
	var areas_sobrepostas := get_overlapping_areas()
	var iterator := EnemyCollection.new(get_tree()).criar_iterator()
	while iterator.has_next():
		var inimigo := iterator.next()
		for area in areas_sobrepostas:
			if area.get_parent() == inimigo:
				_aplicar_dano(area)
				areas_sobrepostas.erase(area)
				break

	for area in areas_sobrepostas:
		_aplicar_dano(area)


func _on_explosionArea_area_entered(area):
	_aplicar_dano(area)


func _aplicar_dano(area):
	if area.get_parent().has_method("receber_dano"):
		area.get_parent().receber_dano(forca, global_position)
