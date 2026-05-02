extends Area2D

var forca: int = 0
var dono: Node = null

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_explosionArea_area_entered"))

	await get_tree().physics_frame

	for area in get_overlapping_areas():
		_aplicar_dano(area)


func _on_explosionArea_area_entered(area):
	_aplicar_dano(area)


func _aplicar_dano(area):
	var alvo = area.get_parent()
	
	if alvo.is_in_group("player"):
		alvo.receber_dano(forca, global_position)
