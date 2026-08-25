extends Node

var efeitos_ativos = {}

func adicionar_efeito(alvo, efeito):

	if !efeitos_ativos.has(alvo):
		efeitos_ativos[alvo] = []

	for efeito_existente in efeitos_ativos[alvo]:

		if efeito_existente.get_script() == efeito.get_script():
			return

	efeitos_ativos[alvo].append(efeito)

	efeito.aplicar(alvo)

func remover_efeito(alvo, efeito):
	if efeitos_ativos.has(alvo):
		efeitos_ativos[alvo].erase(efeito)

func bloquear_dano(alvo) -> bool:
	if !efeitos_ativos.has(alvo):
		return false

	for efeito in efeitos_ativos[alvo]:
		if efeito is EscudoDecorator:
			return true

	return false
