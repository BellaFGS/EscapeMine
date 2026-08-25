extends Node

signal tempo_alterado(valor)

var tempo_total: float = 0.0

# Estado da partida
var player_tem_chave: bool = false
var estado: String = "RUNNING"
var upgrade_pendente: String = ""

# Atributos persistentes do Player
var player_vida_max: int = 100
var player_forca: int = 1
var player_dinamite: int = 0


func _ready():
	pass


func _process(delta):

	if estado != "RUNNING":
		return

	tempo_total += delta

	emit_signal("tempo_alterado", tempo_total)


# ============================================================
# CHAVE
# ============================================================

func pegar_chave():

	player_tem_chave = true

	print("Player pegou a chave.")


func resetar_chave():

	player_tem_chave = false

	print("Chave resetada.")


func tem_chave() -> bool:

	return player_tem_chave


# ============================================================
# ATRIBUTOS DO PLAYER
# ============================================================

func salvar_atributos_player(player):

	player_vida_max = player.vida_max
	player_forca = player.forca
	player_dinamite = player.dinamite


func carregar_atributos_player(player):

	player.vida_max = player_vida_max
	player.vida = player_vida_max
	player.forca = player_forca
	player.dinamite = player_dinamite


# ============================================================
# FINALIZAÇÃO
# ============================================================

func finalizar_jogo(resultado: String):

	estado = resultado
	ScoreManager.finalizar_partida(resultado)

	print("Fim de jogo: ", resultado)

	if resultado == "WIN":

		GameFacade.vitoria()

	elif resultado == "LOSE":

		GameFacade.game_over()


# ============================================================
# RESET DA PARTIDA
# ============================================================

func resetar():
	print("Resetando estado do jogo...")
	estado = "RUNNING"
	tempo_total = 0.0
	player_tem_chave = false
	upgrade_pendente = ""
	player_vida_max = 100
	player_forca = 1
	player_dinamite = 0
	ScoreManager.iniciar_partida()
	UpgradeSystem.resetar()
	print("Estado do jogo resetado.")

func resetarChave():
	player_tem_chave = false
