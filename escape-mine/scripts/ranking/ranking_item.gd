extends HBoxContainer

@onready var data: Label = $BoxContainer/MarginContainer/HSplitContainer/Data
@onready var nome: Label = $BoxContainer/MarginContainer/HSplitContainer/Nome
@onready var pontuacao: Label = $BoxContainer/MarginContainer/HSplitContainer/Pontuacao
@onready var resultado: Label = $BoxContainer/MarginContainer/HSplitContainer/Resultado
@onready var posicao: Label = $BoxContainer/MarginContainer/HSplitContainer/Posicao


func configurar(dados: Dictionary, num_posicao: int) -> void:
	posicao.text = str(num_posicao) + "º"
	nome.text = str(dados.get("nome", ""))
	
	var data_original = str(dados.get("data", ""))
	
	if data_original != "":
		var partes = data_original.split(" ")
		var data_partes = partes[0].split("-")
		
		if data_partes.size() == 3:
			data.text = "%s/%s/%s" % [
				data_partes[2],
				data_partes[1],
				data_partes[0]
			]
		else:
			data.text = data_original
	else:
		data.text = ""

	pontuacao.text = str(dados.get("pontos", 0))
	resultado.text = str(dados.get("resultado", ""))
