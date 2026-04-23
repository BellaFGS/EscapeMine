extends Node

var pedras: int = 0
var dinamites: int = 0

func adicionar_item(tipo: String):
	match tipo:
		"pedra":
			pedras += 1
		"dinamite":
			dinamites += 1

func usar_item(tipo: String) -> bool:
	match tipo:
		"pedra":
			if pedras > 0:
				pedras -= 1
				return true
		"dinamite":
			if dinamites > 0:
				dinamites -= 1
				return true
	return false
