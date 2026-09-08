extends Node2D


var itens := {
	"dinamite": 0,
	"chave": 0
}


func _ready():

	# Recupera o inventário persistente da partida.
	itens["dinamite"] = GameManager.player_dinamite


# ============================================================
# ADICIONAR ITEM
# ============================================================

func adicionar_item(
	nome,
	quantidade
):

	if not itens.has(nome):
		return

	itens[nome] += quantidade

	# Persiste a quantidade.
	if nome == "dinamite":

		GameManager.player_dinamite = (
			itens[nome]
		)


# ============================================================
# USAR ITEM
# ============================================================

func usar_item(nome):

	if not itens.has(nome):
		return false

	if itens[nome] <= 0:
		return false

	itens[nome] -= 1

	# Persiste a quantidade.
	if nome == "dinamite":

		GameManager.player_dinamite = (
			itens[nome]
		)

	return true


# ============================================================
# CONSULTAR QUANTIDADE
# ============================================================

func quantidade_item(nome):

	if not itens.has(nome):
		return 0

	return itens[nome]
