extends Node

var enemy_scene
var vida
var forca
var cor


func set_scene(scene):

	enemy_scene = scene

	print("Builder recebeu cena: ", enemy_scene)

	return self


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

	if enemy_scene == null:

		push_error(
			"EnemyBuilder: enemy_scene está NULL!"
		)

		return null


	print(
		"Instanciando: ",
		enemy_scene.resource_path
	)

	var enemy = enemy_scene.instantiate()

	return enemy
