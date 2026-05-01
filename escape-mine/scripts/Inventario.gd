extends Node


var itens = {
	"dinamite": 0
}

func adicionar_item(nome, quantidade):
	if nome in itens:
		itens[nome] += quantidade

func usar_item(nome):
	if itens[nome] > 0:
		itens[nome] -= 1
		return true
	return false
