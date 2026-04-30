extends Control

@onready var barra_vida = $BarraVidaTextura
@onready var barra_dano = $BarraDanoTextura
@onready var barra_xp = $BarraXpTextura
@onready var texto_vida = $TextoVida
@onready var texto_força = $TextoForca
@onready var texto_xp = $TextoXp
@onready var texto_nivel = $Nivel
@onready var texto_dificuldade = $Nivel_Dificuldade
#@onready var text_timer = $container/contador_container/text_contador

func _ready():
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		print("Player não encontrado")
		return
	
	player.vida_alterada.connect(atualizar_vida)
	player.forca_alterado.connect(forca_alterado)
	player.xp_alterado.connect(xp_alterado)
	player.nivel_up.connect(nivel_up)
	GameManager.dificuldade_alterada.connect(dificuldade_alterada)

	atualizar_vida(player.vida)
	forca_alterado(player.forca)
	xp_alterado(player.xp)
	nivel_up(player.nivel)
	dificuldade_alterada(GameManager.dificuldade, GameManager.get_dificuldade_nome())
	
	
func atualizar_vida(valor):
	var player = get_tree().get_first_node_in_group("player")
	barra_vida.value = valor
	texto_vida.text = str(player.vida) + "/" + str(player.vida_max);

func forca_alterado(valor):
	var player = get_tree().get_first_node_in_group("player")
	barra_dano.value = valor
	texto_força.text = str(player.forca);

func xp_alterado(valor):
	var player = get_tree().get_first_node_in_group("player")
	barra_xp.value = valor
	barra_xp.max_value = player.limite
	texto_xp.text = str(player.xp) + "/" + str(player.limite);
	
func nivel_up(valor):
	texto_nivel.text = str(valor)
	
func dificuldade_alterada(nivel, nome):
	texto_dificuldade.text = nome
	
#func atualizar_tempo(valor):
	#text_timer.text = str(int(valor))
