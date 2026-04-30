extends Node

var slime_scene
var vida 
var forca 
var cor

func set_vida(v):
	vida = v
	return self

func set_forca(f):
	forca = f
	return self

func set_color(c):
	cor = c
	return self

func build():
	var slime = slime_scene.instantiate()
	
	slime.vida_max = vida
	slime.vida = vida
	slime.forca = forca
	
	# 🔥 GARANTE QUE SET_COR É CHAMADO DEPOIS QUE O NODE EXISTE
	slime.call_deferred("set_cor", cor)
	
	return slime
