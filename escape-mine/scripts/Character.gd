extends CharacterBody2D

var vida = 100
var dano = 10
var speed = 100

func mover(direcao):
	velocity = direcao * speed
	move_and_slide()

func receber_dano(valor):
	vida -= valor
	
	if vida <= 0:
		morrer()

func morrer():
	queue_free()
