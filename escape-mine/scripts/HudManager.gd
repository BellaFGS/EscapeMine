extends Control

@onready var barra_vida = $container/barras_player/VBoxContainer/BarraVida
@onready var barra_dano = $container/barras_player/VBoxContainer/BarraDano
#@onready var text_timer = $container/contador_container/text_contador

func _ready():
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		print("Player não encontrado")
		return
	
	player.vida_alterada.connect(atualizar_vida)
	player.dano_alterado.connect(atualizar_dano)

	atualizar_vida(player.vida)
	atualizar_dano(player.dano)
	
	
func atualizar_vida(valor):
	barra_vida.value = valor

func atualizar_dano(valor):
	barra_dano.value = valor

#func atualizar_tempo(valor):
	#text_timer.text = str(int(valor))
