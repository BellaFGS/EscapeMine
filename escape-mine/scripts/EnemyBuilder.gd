extends Node

var slime_scene
var vida = 5
var forca = 10
var cor = Color(0, 1, 0)

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
	
	if slime.texture:
		slime.texture.modulate = cor
	
	return slime
