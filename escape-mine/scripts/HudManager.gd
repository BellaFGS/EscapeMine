extends Control

@onready var barra_vida = $BarraVidaTextura
@onready var barra_dano = $BarraDanoTextura
#@onready var text_timer = $container/contador_container/text_contador

func _ready():
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		print("Player não encontrado")
		return
	
	player.vida_alterada.connect(atualizar_vida)
	player.forca_alterado.connect(forca_alterado)

	atualizar_vida(player.vida)
	forca_alterado(player.forca)
	
	
func atualizar_vida(valor):
	barra_vida.value = valor

func forca_alterado(valor):
	barra_dano.value = valor

#func atualizar_tempo(valor):
	#text_timer.text = str(int(valor))
